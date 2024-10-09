import '../models/health_data.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user_health_data.dart';
import 'database_helper.dart';

class UserHealthDataRepo {
  static const table = 'users';

  static const String createTableStr = '''
    CREATE TABLE $table (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      group_id INTEGER,
      first_name TEXT NOT NULL,
      last_name TEXT NOT NULL,
      age INTEGER NOT NULL,
      height REAL NOT NULL,
      weight REAL NOT NULL,
      heart_rate INTEGER NOT NULL,
      systolic_BP INTEGER NOT NULL,
      diastolic_BP INTEGER NOT NULL,
      activity_level INTEGER NOT NULL,
      health_index REAL NOT NULL,
      is_deleted INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (group_id) REFERENCES groups(id)
    )
  ''';

  // Insert a record
  Future<int> insertRecord(UserHealthData userHealthData) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(table, userHealthData.toMap());
  }

  // Fetch all records that are not soft deleted
  Future<List<UserHealthData>> fetchRecords() async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      table,
      where: 'is_deleted = 0',
    );

    return result.map((row) {
      return UserHealthData(
        id: row['id'],
        groupId: row['group_id'],
        firstName: row['first_name'],
        lastName: row['last_name'],
        healthData: HealthData(
          age: row['age'],
          height: row['height'],
          weight: row['weight'],
          heartRate: row['heart_rate'],
          systolicBP: row['systolic_BP'],
          diastolicBP: row['diastolic_BP'],
          activityLevel: row['activity_level'],
        ),
        healthIndex: row['health_index'],
      );
    }).toList();
  }

  // Perform a soft delete by updating the is_deleted column
  Future<int> softDeleteRecord(int id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      table,
      {'is_deleted': 1}, // Mark as deleted
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update a record, respecting soft delete
  Future<int> updateRecord(UserHealthData userHealthData) async {
    Database db = await DatabaseHelper.instance.database;
    // Only update records that are not soft deleted
    return await db.update(
      table,
      userHealthData.toMap(),
      where: 'id = ? AND is_deleted = 0', // Ensure we're updating only active records
      whereArgs: [userHealthData.id],
    );
  }

  // Physically delete a record (optional)
  Future<int> deleteRecordPermanently(int id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> transferUsersToDefaultGroup(int oldGroupId, int defaultGroupId) async {
    Database db = await DatabaseHelper.instance.database;
    await db.update(
      table,
      {'group_id': defaultGroupId},
      where: 'group_id = ?',
      whereArgs: [oldGroupId],
    );
  }

  Future<List<UserHealthData>> fetchRecordsByGroups(List<int>? groupIds) async {
    Database db = await DatabaseHelper.instance.database;
    String whereClause = 'is_deleted = 0';
    List<dynamic> whereArgs = [];

    if (groupIds != null && groupIds.isNotEmpty) {
      whereClause += ' AND group_id IN (${groupIds.map((_) => '?').join(', ')})';
      whereArgs.addAll(groupIds);
    }

    final List<Map<String, dynamic>> result = await db.query(
      table,
      where: whereClause,
      whereArgs: whereArgs,
    );

    return result.map((row) {
      return UserHealthData(
        id: row['id'],
        groupId: row['group_id'],
        firstName: row['first_name'],
        lastName: row['last_name'],
        healthData: HealthData(
          age: row['age'],
          height: row['height'],
          weight: row['weight'],
          heartRate: row['heart_rate'],
          systolicBP: row['systolic_BP'],
          diastolicBP: row['diastolic_BP'],
          activityLevel: row['activity_level'],
        ),
        healthIndex: row['health_index'],
      );
    }).toList();
  }
}
