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
      version: 2,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
    CREATE TABLE collection (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
    ''');

    await db.execute('''
      CREATE TABLE todo_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        collection_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY(collection_id) REFERENCES collection(id) ON DELETE CASCADE
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE collection (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        )
      ''');

      await db.execute('''
        ALTER TABLE todo_lists
        ADD COLUMN collection_id INTEGER NOT NULL DEFAULT 0
      ''');
    }
  }

  // CRUD FUNCTIONS
  Future<int> addCollection(String name) async {
    final db = await database;
    return await db.insert('collection', {'name': name});
  }

  Future<int> addTodoList(String name, int collectionId) async {
    final db = await database;
    return await db.insert(
      'todo_lists',
      {
        'collection_id': collectionId,
        'name': name,
      },
    );
  }


  Future<int> addTask(int listId, String name) async {
    final db = await database;
    return await db.insert('tasks', {
      'list_id': listId,
      'name': name,
      'is_finished': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getAllCollections() async {
    final db = await database;
    return await db.query('collection');
  }

  Future<List<Map<String, dynamic>>> getAllTodoLists(int collectionId) async {
    final db = await database;
    return await db.query(
      'todo_lists',
      where: 'collection_id = ?',
      whereArgs: [collectionId],
    );
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

  Future<void> deleteCollection(int id) async {
    final db = await database;
    await db.delete(
      'collection',
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
