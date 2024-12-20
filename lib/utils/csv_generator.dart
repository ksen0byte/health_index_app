import 'package:csv/csv.dart';
import 'package:health_index_app/models/user_health_data.dart';

Future<String> generateUserDataCSV(List<UserHealthData> users) async {
  List<List<dynamic>> rows = [];

  // Add header
  rows.add([
    'id',
    'firstName',
    'lastName',
    'folderId',
    'age',
    'height',
    'weight',
    'heartRate',
    'systolicBP',
    'diastolicBP',
    'activityLevel',
    'healthIndex',
  ]);

  for (var user in users) {
    rows.add([
      user.id,
      user.firstName,
      user.lastName,
      user.folderId,
      user.healthData.age,
      user.healthData.height,
      user.healthData.weight,
      user.healthData.heartRate,
      user.healthData.systolicBP,
      user.healthData.diastolicBP,
      user.healthData.activityLevel,
      user.healthIndex,
    ]);
  }

  String csvData = const ListToCsvConverter().convert(rows);
  return csvData;
}
