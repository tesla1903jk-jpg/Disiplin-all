import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/goal_model.dart';
import '../models/journal_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('discipline_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE journals (
        date TEXT PRIMARY KEY,
        wins TEXT NOT NULL,
        struggles TEXT NOT NULL,
        disciplineScore INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertGoal(Goal goal) async {
    final db = await instance.database;
    return await db.insert('goals', goal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Goal>> getGoalsByDateAndType(String date, GoalType type) async {
    final db = await instance.database;
    final maps = await db.query(
      'goals',
      where: 'date = ? AND type = ?',
      whereArgs: [date, type.name],
    );
    return maps.map((map) => Goal.fromMap(map)).toList();
  }

  Future<int> updateGoalStatus(String id, bool isCompleted) async {
    final db = await instance.database;
    return await db.update(
      'goals',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGoal(String id) async {
    final db = await instance.database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertOrUpdateJournal(JournalEntry journal) async {
    final db = await instance.database;
    return await db.insert('journals', journal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<JournalEntry?> getJournalByDate(String date) async {
    final db = await instance.database;
    final maps = await db.query(
      'journals',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (maps.isNotEmpty) {
      return JournalEntry.fromMap(maps.first);
    }
    return null;
  }
}
