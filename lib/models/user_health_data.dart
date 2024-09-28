import 'health_data.dart';

class UserHealthData {
  int? id;
  int? groupId;
  final String firstName;
  final String lastName;
  final HealthData healthData;
  final double healthIndex;

  UserHealthData({
    required this.firstName,
    required this.lastName,
    required this.healthData,
    required this.healthIndex,
    this.groupId,
    this.id,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'first_name': firstName,
      'last_name': lastName,
      'age': healthData.age,
      'height': healthData.height,
      'weight': healthData.weight,
      'heart_rate': healthData.heartRate,
      'systolic_BP': healthData.systolicBP,
      'diastolic_BP': healthData.diastolicBP,
      'health_index': healthIndex,
    };
  }

  @override
  String toString() {
    return 'UserHealthData{id: $id, groupId: $groupId, firstName: $firstName, lastName: $lastName, healthIndex: $healthIndex, healthData: $healthData}';
  }
}
