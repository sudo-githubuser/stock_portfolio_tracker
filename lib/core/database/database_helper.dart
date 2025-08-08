import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/holding_model.dart';
import '../models/stock_model.dart';

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
    String path = join(await getDatabasesPath(), 'portfolio.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Holdings table
    await db.execute('''
      CREATE TABLE holdings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        avgPrice REAL NOT NULL,
        currentPrice REAL NOT NULL,
        source TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Stock prices cache table
    await db.execute('''
      CREATE TABLE stock_prices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        currentPrice REAL NOT NULL,
        previousClose REAL NOT NULL,
        change REAL NOT NULL,
        changePercent REAL NOT NULL,
        currency TEXT NOT NULL,
        lastUpdated TEXT NOT NULL
      )
    ''');

    // Transactions table for buy/sell history
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        type TEXT NOT NULL,
        quantity REAL NOT NULL,
        price REAL NOT NULL,
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // Holdings CRUD operations
  Future<int> insertHolding(HoldingModel holding) async {
    final db = await database;
    return await db.insert('holdings', holding.toDbMap());
  }

  Future<List<HoldingModel>> getAllHoldings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('holdings');
    return List.generate(maps.length, (i) => HoldingModel.fromJson(maps[i]));
  }

  Future<HoldingModel?> getHoldingBySymbol(String symbol) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'holdings',
      where: 'symbol = ?',
      whereArgs: [symbol],
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

  Future<int> deleteHolding(int id) async {
    final db = await database;
    return await db.delete(
      'holdings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteHoldingBySymbol(String symbol) async {
    final db = await database;
    return await db.delete(
      'holdings',
      where: 'symbol = ?',
      whereArgs: [symbol],
    );
  }

  // Stock prices CRUD operations
  Future<int> insertOrUpdateStockPrice(StockModel stock) async {
    final db = await database;
    return await db.insert(
      'stock_prices',
      stock.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StockModel>> getAllStockPrices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('stock_prices');
    return List.generate(maps.length, (i) => StockModel.fromJson(maps[i]));
  }

  Future<StockModel?> getStockPriceBySymbol(String symbol) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_prices',
      where: 'symbol = ?',
      whereArgs: [symbol],
    );
    if (maps.isNotEmpty) {
      return StockModel.fromJson(maps.first);
    }
    return null;
  }

  // Transaction operations
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactionsBySymbol(String symbol) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'symbol = ?',
      whereArgs: [symbol],
      orderBy: 'date DESC',
    );
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('holdings');
    await db.delete('stock_prices');
    await db.delete('transactions');
  }

  // Database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;
    final holdingsCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM holdings')
    ) ?? 0;
    final stockPricesCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM stock_prices')
    ) ?? 0;
    final transactionsCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM transactions')
    ) ?? 0;

    return {
      'holdings': holdingsCount,
      'stockPrices': stockPricesCount,
      'transactions': transactionsCount,
    };
  }
}
