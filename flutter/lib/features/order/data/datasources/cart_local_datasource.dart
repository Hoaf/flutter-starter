import 'package:flutter_demo/features/order/domain/entities/cart_item_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

@lazySingleton
class CartLocalDatasource {
  static const _dbName = 'cart.db';
  static const _tableName = 'cart_items';

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
          product_id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          price REAL NOT NULL,
          price_unit TEXT NOT NULL,
          image TEXT,
          quantity INTEGER NOT NULL DEFAULT 1
        )
      '''),
      version: 1,
    );
  }

  /// Increments quantity if item exists, otherwise inserts with quantity 1.
  Future<void> addItem(CartItemEntity item) async {
    final db = await database;
    final existing = await db.query(
      _tableName,
      where: 'product_id = ?',
      whereArgs: [item.productId],
      limit: 1,
    );
    if (existing.isEmpty) {
      await db.insert(_tableName, item.toMap());
    } else {
      final currentQty = existing.first['quantity'] as int;
      await db.update(
        _tableName,
        {'quantity': currentQty + 1},
        where: 'product_id = ?',
        whereArgs: [item.productId],
      );
    }
  }

  /// Decrements quantity. Deletes the row when quantity reaches 0.
  Future<void> removeItem(int productId) async {
    final db = await database;
    final existing = await db.query(
      _tableName,
      where: 'product_id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    if (existing.isEmpty) return;
    final currentQty = existing.first['quantity'] as int;
    if (currentQty <= 1) {
      await db.delete(
        _tableName,
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } else {
      await db.update(
        _tableName,
        {'quantity': currentQty - 1},
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    }
  }

  Future<List<CartItemEntity>> getItems() async {
    final db = await database;
    final maps = await db.query(_tableName);
    return maps.map(CartItemEntity.fromMap).toList();
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
