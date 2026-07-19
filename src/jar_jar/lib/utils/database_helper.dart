import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/saving_method.dart';

/// SQLite 数据库管理单例
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  static DatabaseHelper get instance => _instance ??= DatabaseHelper._();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'jar_jar.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        method_id TEXT NOT NULL,
        method_name TEXT NOT NULL,
        start_date TEXT NOT NULL,
        target_amount REAL NOT NULL,
        saved_amount REAL DEFAULT 0,
        status TEXT DEFAULT 'active',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        is_completed INTEGER DEFAULT 0,
        FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        earned_date TEXT,
        plan_id INTEGER
      )
    ''');
  }

  // ========== Plan CRUD ==========

  Future<int> insertPlan(UserPlan plan) async {
    final db = await database;
    return db.insert('plans', {
      'method_id': plan.methodId,
      'method_name': plan.methodName,
      'start_date': plan.startDate.toIso8601String().split('T')[0],
      'target_amount': plan.targetAmount,
      'saved_amount': plan.savedAmount,
      'status': plan.status,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<UserPlan?> getActivePlan() async {
    final db = await database;
    final results = await db.query(
      'plans',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return _mapPlan(results.first);
  }

  Future<List<UserPlan>> getAllPlans() async {
    final db = await database;
    final results = await db.query('plans', orderBy: 'created_at DESC');
    return results.map(_mapPlan).toList();
  }

  Future<int> updatePlan(UserPlan plan) async {
    final db = await database;
    return db.update(
      'plans',
      {
        'saved_amount': plan.savedAmount,
        'status': plan.status,
      },
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  Future<int> deletePlan(int id) async {
    final db = await database;
    await db.delete('records', where: 'plan_id = ?', whereArgs: [id]);
    return db.delete('plans', where: 'id = ?', whereArgs: [id]);
  }

  // ========== Record CRUD ==========

  Future<int> insertRecord(SavingRecord record) async {
    final db = await database;
    return db.insert('records', {
      'plan_id': record.planId,
      'date': record.date.toIso8601String().split('T')[0],
      'amount': record.amount,
      'is_completed': record.isCompleted ? 1 : 0,
    });
  }

  Future<List<SavingRecord>> getRecordsByPlan(int planId) async {
    final db = await database;
    final results = await db.query(
      'records',
      where: 'plan_id = ?',
      whereArgs: [planId],
      orderBy: 'date DESC',
    );
    return results.map(_mapRecord).toList();
  }

  Future<bool> hasTodayRecord(int planId) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final result = await db.query(
      'records',
      where: 'plan_id = ? AND date = ?',
      whereArgs: [planId, today],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // ========== Badge CRUD ==========

  Future<int> insertBadge({
    required String name,
    String? description,
    String? icon,
    int? planId,
  }) async {
    final db = await database;
    return db.insert('badges', {
      'name': name,
      'description': description,
      'icon': icon,
      'earned_date': DateTime.now().toIso8601String(),
      'plan_id': planId,
    });
  }

  Future<List<Map<String, dynamic>>> getBadges() async {
    final db = await database;
    return db.query('badges', orderBy: 'earned_date DESC');
  }

  // ========== Mappers ==========

  UserPlan _mapPlan(Map<String, dynamic> row) {
    return UserPlan(
      id: row['id'] as int,
      methodId: row['method_id'] as String,
      methodName: row['method_name'] as String,
      startDate: DateTime.parse(row['start_date'] as String),
      targetAmount: (row['target_amount'] as num).toDouble(),
      savedAmount: (row['saved_amount'] as num?)?.toDouble() ?? 0,
      status: row['status'] as String? ?? 'active',
    );
  }

  SavingRecord _mapRecord(Map<String, dynamic> row) {
    return SavingRecord(
      id: row['id'] as int,
      planId: row['plan_id'] as int,
      date: DateTime.parse(row['date'] as String),
      amount: (row['amount'] as num).toDouble(),
      isCompleted: (row['is_completed'] as int?) == 1,
    );
  }
}
