import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

@lazySingleton
class UserLocalDatasource {
  static const _dbName = 'app.db';
  static const _tableName = 'user_profile';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, _dbName),
      onCreate: (db, version) => db.execute('''
        CREATE TABLE $_tableName (
          id INTEGER PRIMARY KEY,
          username TEXT NOT NULL,
          email TEXT,
          first_name TEXT,
          last_name TEXT,
          age INTEGER,
          role TEXT
        )
      '''),
      version: 1,
    );
  }

  Future<void> saveUser(UserEntity user) async {
    final db = await database;
    await db.insert(
      _tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserEntity?> getUser() async {
    final db = await database;
    final maps = await db.query(_tableName, limit: 1);
    if (maps.isEmpty) return null;
    return UserEntity.fromMap(maps.first);
  }

  Future<void> clearUser() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
