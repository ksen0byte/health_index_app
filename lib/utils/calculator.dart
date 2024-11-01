import 'package:flutter/material.dart';

import '../models/health_index.dart';
import '../models/health_data.dart';

enum ActivityLevel {
  level1,
  level2,
  level3,
  level4,
  level5,
  level6,
  level7,
}

final Map<ActivityLevel, String> activityLevelDescriptions = {
  ActivityLevel.level1: '1 - Мінімальні навантаження (працівники розумової праці, сидяча робота)',
  ActivityLevel.level2: '2 - Трохи денної активності або легкі вправи 2-3 рази на тиждень',
  ActivityLevel.level3: '3 - Робота середньої тяжкості або тренування 4-5 разів на тиждень',
  ActivityLevel.level4: '4 - Інтенсивні тренування 4-5 разів на тиждень',
  ActivityLevel.level5: '5 - Щоденні тренування',
  ActivityLevel.level6: '6 - Щоденні інтенсивні тренування або тренування 2 рази в день',
  ActivityLevel.level7: '7 - Важка фізична робота або інтенсивні тренування 2 рази в день',
};


final Map<AgeGroup, AgeGroupIndexRanges> indexByAgeGroup = {
  AgeGroup.age13to14: AgeGroupIndexRanges(
    high: IndexRange(0, 2.09),
    aboveAverage: IndexRange(2.09, 2.3),
    average: IndexRange(2.3, 2.7),
    belowAverage: IndexRange(2.7, 2.93),
    low: IndexRange(2.93, double.infinity),
  ),
  AgeGroup.age15to16: AgeGroupIndexRanges(
    high: IndexRange(0, 2.28),
    aboveAverage: IndexRange(2.28, 2.5),
    average: IndexRange(2.5, 2.94),
    belowAverage: IndexRange(2.94, 3.17),
    low: IndexRange(3.17, double.infinity),
  ),
  AgeGroup.age17: AgeGroupIndexRanges(
    high: IndexRange(0, 2.36),
    aboveAverage: IndexRange(2.36, 2.59),
    average: IndexRange(2.59, 3.0),
    belowAverage: IndexRange(3.0, 3.23),
    low: IndexRange(3.23, double.infinity),
  ),
  AgeGroup.age18to22: AgeGroupIndexRanges(
    high: IndexRange(0, 2.20),
    aboveAverage: IndexRange(2.20, 2.42),
    average: IndexRange(2.42, 2.87),
    belowAverage: IndexRange(2.87, 3.0),
    low: IndexRange(3.0, double.infinity),
  ),
  AgeGroup.age23to29: AgeGroupIndexRanges(
    high: IndexRange(0, 2.27),
    aboveAverage: IndexRange(2.27, 2.5),
    average: IndexRange(2.5, 2.95),
    belowAverage: IndexRange(2.95, 3.18),
    low: IndexRange(3.18, double.infinity),
  ),
  AgeGroup.age30to39: AgeGroupIndexRanges(
    high: IndexRange(0, 2.36),
    aboveAverage: IndexRange(2.36, 2.6),
    average: IndexRange(2.6, 3.0),
    belowAverage: IndexRange(3.0, 3.23),
    low: IndexRange(3.23, double.infinity),
  ),
  AgeGroup.age40to59: AgeGroupIndexRanges(
    high: IndexRange(0, 2.96),
    aboveAverage: IndexRange(2.96, 3.2),
    average: IndexRange(3.2, 3.6),
    belowAverage: IndexRange(3.6, 3.83),
    low: IndexRange(3.83, double.infinity),
  ),
};

final Map<HealthIndexLevel, HealthIndexLevelResult> resultByHealthIndexLevel = {
  HealthIndexLevel.high: HealthIndexLevelResult(
    color: Colors.green,
    text: 'Високий',
    longTermHealthForecast: LongTermHealthForecast(text: 'Прогноз високий (100-110%)', value: 1.1),
    geneticLifeExpectancy: GeneticLifeExpectancy(text: 'Збільшена Вами на 10%', value: 1.1),
    diseaseRisk: DiseaseRisk(text: 'Низький (1-6%)', value: 0.02),
  ),
  HealthIndexLevel.aboveAverage: HealthIndexLevelResult(
    color: Colors.lightGreen,
    text: 'Вище Середнього',
    longTermHealthForecast: LongTermHealthForecast(text: 'Прогноз високий (100-110%)', value: 1.0),
    geneticLifeExpectancy: GeneticLifeExpectancy(text: 'Незмінна (100%)', value: 1.0),
    diseaseRisk: DiseaseRisk(text: 'Низький (1-6%)', value: 0.05),
  ),
  HealthIndexLevel.average: HealthIndexLevelResult(
    color: Colors.yellow,
    text: 'Середній',
    longTermHealthForecast: LongTermHealthForecast(text: 'Прогноз задовільний (90%)', value: 0.9),
    geneticLifeExpectancy: GeneticLifeExpectancy(text: 'Скорочена Вами на 10%', value: 0.9),
    diseaseRisk: DiseaseRisk(text: 'Підвищений (20-30%)', value: 0.2),
  ),
  HealthIndexLevel.belowAverage: HealthIndexLevelResult(
    color: Colors.orange,
    text: 'Нижче Середнього',
    longTermHealthForecast: LongTermHealthForecast(text: 'Прогноз незадовільний (70-75%)', value: 0.7),
    geneticLifeExpectancy: GeneticLifeExpectancy(text: 'Скорочена Вами на 25%', value: 0.75),
    diseaseRisk: DiseaseRisk(text: 'Підвищений (20-30%)', value: 0.3),
  ),
  HealthIndexLevel.low: HealthIndexLevelResult(
    color: Colors.red,
    text: 'Низький',
    longTermHealthForecast: LongTermHealthForecast(text: 'Прогноз незадовільний (70-75%)', value: 0.7),
    geneticLifeExpectancy: GeneticLifeExpectancy(text: 'Скорочена Вами на 30%', value: 0.7),
    diseaseRisk: DiseaseRisk(text: 'Високий (60%)', value: 0.6),
  ),
};

HealthIndex calculateHealthIndex(HealthData data) {
  // check if data is valid
  validateInput(data);

  // Main Formula
  double index = calculateIndex(data);

  // group by age
  AgeGroup ageGroup = getAgeGroup(data.age);
  AgeGroupIndexRanges ranges = indexByAgeGroup[ageGroup]!;
  HealthIndexLevel level = healthIndexToLevelByAge(index, ranges);

  return HealthIndex(index: index, healthIndexLevel: level, healthIndexLevelResult: resultByHealthIndexLevel[level]!);
}

void validateInput(HealthData data) {
  if (data.age <= 0 ||
      data.height <= 0 ||
      data.weight <= 0 ||
      data.heartRate <= 0 ||
      data.systolicBP <= 0 ||
      data.diastolicBP <= 0) {
    throw ArgumentError('Всі значення повинні бути позитивними числами.');
  }
}

double calculateIndex(HealthData data) {
  double index = 0.008322 * data.age -
      0.005102 * data.height +
      0.008964 * data.weight +
      0.009942 * data.heartRate +
      0.017878 * data.systolicBP +
      0.008174 * data.diastolicBP -
      0.481156;
  return index;
}

HealthIndexLevel healthIndexToLevelByAge(double index, AgeGroupIndexRanges ranges) {
  if (ranges.high.contains(index)) {
    return HealthIndexLevel.high;
  } else if (ranges.aboveAverage.contains(index)) {
    return HealthIndexLevel.aboveAverage;
  } else if (ranges.average.contains(index)) {
    return HealthIndexLevel.average;
  } else if (ranges.belowAverage.contains(index)) {
    return HealthIndexLevel.belowAverage;
  } else {
    return HealthIndexLevel.low;
  }
}
