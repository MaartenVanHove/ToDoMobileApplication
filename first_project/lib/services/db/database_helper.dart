import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseServices {
  static final DatabaseServices instance = DatabaseServices._init();
  static Database? _database;

  DatabaseServices._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await createDatabase();
    return _database!;
  }

  Future<Database> createDatabase() async {
    final path = join(await getDatabasesPath(), 'master_db.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todo_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        is_finished INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(list_id) REFERENCES todo_lists(id) ON DELETE CASCADE
      )
    ''');
  }

  // CRUD FUNCTIONS
  Future<int> addTodoList(String name) async {
    final db = await database;
    return await db.insert('todo_lists', {'name': name});
  }

  Future<int> addTask(int listId, String name) async {
    final db = await database;
    return await db.insert('tasks', {
      'list_id': listId,
      'name': name,
      'is_finished': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getAllTodoLists() async {
    final db = await database;
    return await db.query('todo_lists');
  }

  Future<List<Map<String, dynamic>>> getTasks(int listId) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'list_id = ?',
      whereArgs: [listId],
    );
  }

  Future<void> updateTaskFinished(int id, bool finished) async {
    final db = await database;
    await db.update(
      'tasks',
      {'is_finished': finished ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTodoList(int id) async {
    final db = await database;
    await db.delete(
      'todo_lists',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
