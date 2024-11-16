import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../models/health_index.dart';

class ResultScreen extends StatelessWidget {
  final HealthIndex healthIndex;

  const ResultScreen({super.key, required this.healthIndex});

  Widget _buildLinearGauge({
    required double value,
    required double minValue,
    required double maxValue,
    bool inverted = false,
  }) {
    return SfLinearGauge(
      labelFormatterCallback: (value) => '$value%',
      maximumLabels: 1,
      isAxisInversed: inverted,
      isMirrored: true,
      minimum: minValue,
      maximum: maxValue,
      showTicks: true,
      showLabels: true,
      axisTrackStyle: const LinearAxisTrackStyle(
        thickness: 20,
        edgeStyle: LinearEdgeStyle.bothFlat,
        gradient: LinearGradient(
          colors: [Colors.redAccent, Colors.yellowAccent, Colors.lightGreen],
          stops: [0.0, 0.7, 1.0],
        ),
      ),
      markerPointers: [
        LinearShapePointer(
          value: value,
          shapeType: LinearShapePointerType.diamond,
          color: Colors.black,
          position: LinearElementPosition.cross,
          height: 20,
        ),
      ],
      minorTicksPerInterval: 4,
    );
  }

  Widget _buildInterpretationSection({
    required String title,
    required String valueText,
    required IconData icon,
    required Color color,
    double? value,
    double? minValue,
    double? maxValue,
    bool gaugeInverted = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Compact icon with background
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        if (value != null && minValue != null && maxValue != null) ...[
          const SizedBox(height: 6),
          SizedBox(
            height: 50, // Reduce the height of the gauge
            child: _buildLinearGauge(
              value: value,
              minValue: minValue,
              maxValue: maxValue,
              inverted: gaugeInverted,
            ),
          ),
        ],
        const SizedBox(height: 2),
        Text(
          valueText,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Отримуємо кольорову схему
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Row(
          children: [
            Icon(
              Icons.assessment,
              color: colorScheme.onPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              'Результат',
              style: TextStyle(
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              // Додаємо прокручування, якщо контент не вміщується
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Ваш ІФЗ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                // Коло з індексом
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: healthIndex.healthIndexLevelResult.color, // Використовуємо основний колір
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      healthIndex.index.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Текст білий для кращого контрасту
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Рівень ІФЗ
                Text(
                  healthIndex.healthIndexLevelResult.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Додаткові інтерпретації
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75, // 50% ширини екрану
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInterpretationSection(
                          title: 'Довготривалий прогноз здоров\'я',
                          valueText: healthIndex.healthIndexLevelResult.longTermHealthForecast.text,
                          icon: Icons.health_and_safety,
                          color: healthIndex.healthIndexLevelResult.color,
                          value: healthIndex.healthIndexLevelResult.longTermHealthForecast.value * 100,
                          minValue: 70,
                          maxValue: 110,
                        ),
                        _buildInterpretationSection(
                          title: 'Генетична програма тривалості життя',
                          valueText: healthIndex.healthIndexLevelResult.geneticLifeExpectancy.text,
                          icon: Icons.timeline,
                          color: healthIndex.healthIndexLevelResult.color,
                          value: healthIndex.healthIndexLevelResult.geneticLifeExpectancy.value * 100,
                          minValue: 70,
                          maxValue: 110,
                        ),
                        _buildInterpretationSection(
                          title: 'Ризик захворювань з тимчасовою втратою дієздатності',
                          valueText: healthIndex.healthIndexLevelResult.diseaseRisk.text,
                          icon: Icons.warning_amber_rounded,
                          color: healthIndex.healthIndexLevelResult.color,
                          value: healthIndex.healthIndexLevelResult.diseaseRisk.value * 100,
                          minValue: 0,
                          maxValue: 60,
                          gaugeInverted: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('На головний екран'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
