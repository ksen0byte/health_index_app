import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/group.dart';

class GroupRepo {
  static const defaultGroupName = 'Default Group';
  static const table = 'groups';

  static const String createTableStr = '''
    CREATE TABLE $table (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''';

  Future<int> insertGroup(Group group) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(table, group.toMap());
  }

  Future<List<Group>> fetchGroups() async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query(table);

    return result.map((row) {
      return Group(
        id: row['id'],
        name: row['name'],
      );
    }).toList();
  }

  Future<int> updateGroup(Group group) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      table,
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<int> deleteGroup(int id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Group> getDefaultGroup() async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      table,
      where: 'name = ?',
      whereArgs: [defaultGroupName],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Group(
        id: result.first['id'],
        name: result.first['name'],
      );
    } else {
      // Handle the case where default group doesn't exist
      throw Exception('Default group not found');
    }
  }
}
