import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'group_repo.dart';
import 'user_health_data_repo.dart';

class DatabaseHelper {
  static const _databaseName = "health_index.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    // ignore: avoid_print
    print('Database path: $path'); // This will print the database path

    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(GroupRepo.createTableStr);
    await db.execute(UserHealthDataRepo.createTableStr);

    // Insert default group
    await db.insert(GroupRepo.table, {'name': GroupRepo.defaultGroupName});
  }
}
