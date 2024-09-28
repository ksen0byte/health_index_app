import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../repo/user_health_data_repo.dart';

Future<String> exportUserDataToCSV({List<int>? groupIds}) async {
  final users = await UserHealthDataRepo().fetchRecordsByGroups(groupIds);

  List<List<dynamic>> rows = [];

  // Add header
  rows.add([
    'id',
    'firstName',
    'lastName',
    'groupId',
    'age',
    'height',
    'weight',
    'heartRate',
    'systolicBP',
    'diastolicBP',
    'healthIndex',
  ]);

  for (var user in users) {
    rows.add([
      user.id,
      user.firstName,
      user.lastName,
      user.groupId,
      user.healthData.age,
      user.healthData.height,
      user.healthData.weight,
      user.healthData.heartRate,
      user.healthData.systolicBP,
      user.healthData.diastolicBP,
      user.healthIndex,
    ]);
  }

  String csvData = const ListToCsvConverter().convert(rows);
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/user_data.csv';
  final file = File(path);

  await file.writeAsString(csvData);

  return path;
}
