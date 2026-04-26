import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _dbName = 'budget_tracker.db';
  static const _dbVersion = 1;
  static const budgetsTable = 'budgets';
  static const sessionCartItemsTable = 'session_cart_items';
  static const userProfileTable = 'user_profile';
  static const appSettingsTable = 'app_settings';

  Database? _database;

  Future<Database> get instance async {
    if (_database != null) {
      return _database!;
    }
    _database = await _openDatabase();
    return _database!;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
    }
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onDowngrade: onDatabaseDowngradeDelete,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (db) async {
        await _createUserProfileTable(db);
        await _createBudgetsTable(db);
        await _createSessionCartItemsTable(db);
        await _createAppSettingsTable(db);
      },
      onCreate: (db, version) async {
        await _createUserProfileTable(db);
        await _createBudgetsTable(db);
        await _createSessionCartItemsTable(db);
        await _createAppSettingsTable(db);
      },
    );
  }

  Future<void> _createUserProfileTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $userProfileTable(
        id TEXT PRIMARY KEY CHECK(length(trim(id)) > 0),
        name TEXT NOT NULL CHECK(length(trim(name)) > 0),
        email TEXT NOT NULL CHECK(length(trim(email)) > 0),
        image_url TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL CHECK(length(trim(created_at)) > 0),
        updated_at TEXT NOT NULL CHECK(length(trim(updated_at)) > 0)
      )
    ''');
  }

  Future<void> _createBudgetsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $budgetsTable(
        id TEXT PRIMARY KEY CHECK(length(trim(id)) > 0),
        name TEXT NOT NULL CHECK(length(trim(name)) > 0),
        type TEXT NOT NULL CHECK(type IN ('shopping', 'weekly', 'monthly')),
        amount INTEGER NOT NULL CHECK(amount > 0),
        warning_percent REAL NOT NULL CHECK(warning_percent >= 0 AND warning_percent <= 100),
        is_active INTEGER NOT NULL CHECK(is_active IN (0, 1)),
        created_at TEXT NOT NULL CHECK(length(trim(created_at)) > 0),
        updated_at TEXT NOT NULL CHECK(length(trim(updated_at)) > 0)
      )
    ''');
  }

  Future<void> _createSessionCartItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $sessionCartItemsTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        budget_id TEXT NOT NULL CHECK(length(trim(budget_id)) > 0),
        name TEXT NOT NULL CHECK(length(trim(name)) > 0),
        category TEXT NOT NULL CHECK(length(trim(category)) > 0),
        unit_price INTEGER NOT NULL CHECK(unit_price >= 0),
        quantity INTEGER NOT NULL CHECK(quantity > 0),
        unit TEXT NOT NULL DEFAULT 'PC' CHECK(unit IN ('PC', 'KG')),
        is_essential INTEGER NOT NULL DEFAULT 0 CHECK(is_essential IN (0, 1)),
        source_type TEXT NOT NULL DEFAULT 'manual'
          CHECK(source_type IN ('manual', 'voice', 'label_scan')),
        created_at TEXT NOT NULL CHECK(length(trim(created_at)) > 0),
        FOREIGN KEY (budget_id) REFERENCES $budgetsTable(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${sessionCartItemsTable}_budget_id
      ON $sessionCartItemsTable(budget_id)
    ''');
  }

  Future<void> _createAppSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $appSettingsTable(
        key TEXT PRIMARY KEY CHECK(length(trim(key)) > 0),
        value TEXT NOT NULL
      )
    ''');
  }
}
