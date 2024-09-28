import 'dart:ui';

class HealthIndex {
  double index;
  final HealthIndexLevel healthIndexLevel;
  final HealthIndexLevelResult healthIndexLevelResult;

  HealthIndex({
    required this.index,
    required this.healthIndexLevel,
    required this.healthIndexLevelResult,
  });
}

enum AgeGroup { age13to14, age15to16, age17, age18to22, age23to29, age30to39, age40to59 }

AgeGroup getAgeGroup(int age) {
  if (age >= 13 && age <= 14) return AgeGroup.age13to14;
  if (age >= 15 && age <= 16) return AgeGroup.age15to16;
  if (age == 17) return AgeGroup.age17;
  if (age >= 18 && age <= 22) return AgeGroup.age18to22;
  if (age >= 23 && age <= 29) return AgeGroup.age23to29;
  if (age >= 30 && age <= 39) return AgeGroup.age30to39;
  if (age >= 40 && age <= 59) return AgeGroup.age40to59;
  throw ArgumentError('Invalid age group');
}

enum HealthIndexLevel { high, aboveAverage, average, belowAverage, low }

class IndexRange {
  final double low;
  final double high;

  IndexRange(this.low, this.high);

  bool contains(double index) => index >= low && index < high;
}

class AgeGroupIndexRanges {
  final IndexRange high;
  final IndexRange aboveAverage;
  final IndexRange average;
  final IndexRange belowAverage;
  final IndexRange low;

  AgeGroupIndexRanges({
    required this.high,
    required this.aboveAverage,
    required this.average,
    required this.belowAverage,
    required this.low,
  });
}

class LongTermHealthForecast {
  final String text;
  final double value;

  LongTermHealthForecast({required this.text, required this.value});
}

class GeneticLifeExpectancy {
  final String text;
  final double value;

  GeneticLifeExpectancy({required this.text, required this.value});
}

class DiseaseRisk {
  final String text;
  final double value;

  DiseaseRisk({required this.text, required this.value});
}

class HealthIndexLevelResult {
  final Color color;
  final String text;
  final LongTermHealthForecast longTermHealthForecast;
  final GeneticLifeExpectancy geneticLifeExpectancy;
  final DiseaseRisk diseaseRisk;

  HealthIndexLevelResult(
      {required this.color,
      required this.text,
      required this.longTermHealthForecast,
      required this.geneticLifeExpectancy,
      required this.diseaseRisk});
}
