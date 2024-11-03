import 'health_data.dart';

class UserHealthData {
  int? id;
  int? folderId;
  String firstName;
  String lastName;
  final HealthData healthData;
  final double healthIndex;
  final DateTime recordedAt;

  UserHealthData({
    required this.firstName,
    required this.lastName,
    required this.healthData,
    required this.healthIndex,
    required this.recordedAt,
    this.folderId,
    this.id,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'folder_id': folderId,
      'first_name': firstName,
      'last_name': lastName,
      'age': healthData.age,
      'height': healthData.height,
      'weight': healthData.weight,
      'heart_rate': healthData.heartRate,
      'systolic_BP': healthData.systolicBP,
      'diastolic_BP': healthData.diastolicBP,
      'activity_level': healthData.activityLevel,
      'health_index': healthIndex,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserHealthData{id: $id, folderId: $folderId, firstName: $firstName, lastName: $lastName, healthIndex: $healthIndex, recordedAt: $recordedAt, healthData: $healthData}';
  }
}
