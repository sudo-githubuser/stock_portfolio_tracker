import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/holding_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'portfolio.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE holdings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        avgPrice REAL NOT NULL,
        currentPrice REAL NOT NULL,
        source TEXT NOT NULL,
        isMTF INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_holdings_symbol ON holdings(symbol)
    ''');

    await db.execute('''
      CREATE INDEX idx_holdings_source ON holdings(source)
    ''');
  }

  Future<int> insertHolding(HoldingModel holding) async {
    final db = await database;
    return await db.insert('holdings', holding.toDbMap());
  }

  Future<List<HoldingModel>> getAllHoldings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'holdings',
      orderBy: 'updatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return HoldingModel.fromJson(maps[i]);
    });
  }

  Future<List<HoldingModel>> getHoldingsBySource(String source) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'holdings',
      where: 'source = ?',
      whereArgs: [source],
      orderBy: 'updatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return HoldingModel.fromJson(maps[i]);
    });
  }

  Future<HoldingModel?> getHoldingBySymbol(String symbol, String source) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'holdings',
      where: 'symbol = ? AND source = ?',
      whereArgs: [symbol, source],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return HoldingModel.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateHolding(HoldingModel holding) async {
    final db = await database;
    return await db.update(
      'holdings',
      holding.toDbMap(),
      where: 'id = ?',
      whereArgs: [holding.id],
    );
  }

  Future<int> updateHoldingPrice(int id, double currentPrice) async {
    final db = await database;
    return await db.update(
      'holdings',
      {
        'currentPrice': currentPrice,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteHolding(int id) async {
    final db = await database;
    return await db.delete(
      'holdings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllHoldingsBySource(String source) async {
    final db = await database;
    await db.delete(
      'holdings',
      where: 'source = ?',
      whereArgs: [source],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
