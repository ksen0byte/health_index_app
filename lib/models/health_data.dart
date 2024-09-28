class HealthData {
  int age;
  double height;
  double weight;
  int heartRate;
  int systolicBP;
  int diastolicBP;

  HealthData({
    required this.age,
    required this.height,
    required this.weight,
    required this.heartRate,
    required this.systolicBP,
    required this.diastolicBP,
  });

  @override
  String toString() {
    return 'HealthData(age: $age, height: $height, weight: $weight, heartRate: $heartRate, systolicBP: $systolicBP, diastolicBP: $diastolicBP)';
  }
}


