import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/folder.dart';

class FolderRepo {
  static const defaultFolderName = 'Тека за замовчуванням';
  static const table = 'folders';

  static const String createTableStr = '''
    CREATE TABLE $table (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''';

  Future<int> insertFolder(Folder folder) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(table, folder.toMap());
  }

  Future<List<Folder>> fetchFolders() async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query(table);

    return result.map((row) {
      return Folder(
        id: row['id'],
        name: row['name'],
      );
    }).toList();
  }

  Future<int> updateFolder(Folder folder) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      table,
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  Future<int> deleteFolder(int id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Folder> getDefaultFolder() async {
    Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      table,
      where: 'name = ?',
      whereArgs: [defaultFolderName],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Folder(
        id: result.first['id'],
        name: result.first['name'],
      );
    } else {
      // Handle the case where default folder doesn't exist
      throw Exception('Default folder not found');
    }
  }
}
