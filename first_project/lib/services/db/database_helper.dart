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
      version: 5, // Newest version is 5 to include colors table
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
          image_path TEXT,
          FOREIGN KEY(collection_id) REFERENCES collection(id) ON DELETE CASCADE
        )
      ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        is_finished INTEGER NOT NULL DEFAULT 0,
        image_path TEXT,
        FOREIGN KEY(list_id) REFERENCES todo_lists(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE colors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        hex_value TEXT NOT NULL DEFAULT '#FFFFFF',
        list_id INTEGER NOT NULL,
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

    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE todo_lists 
        ADD COLUMN image_path TEXT
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE tasks 
        ADD COLUMN image_path TEXT
      ''');
    }

    if(oldVersion < 5) {
      await db.execute('''
        CREATE TABLE colors (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          hex_value TEXT NOT NULL,
          list_id INTEGER NOT NULL, 
          FOREIGN KEY(list_id) REFERENCES todo_lists(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // CRUD FUNCTIONS
  Future<int> addCollection(String name) async {
    final db = await database;
    return await db.insert('collection', {'name': name});
  }

  Future<int> addTodoList(String? imagePath, String name, int collectionId) async {
    final db = await database;
    return await db.insert(
      'todo_lists',
      {
        'collection_id': collectionId,
        'name': name,
        'image_path': imagePath,
      },
    );
  }


  Future<int> addTask(String? imagePath, int listId, String name) async {
    final db = await database;
    return await db.insert(
      'tasks', 
      {
        'list_id': listId,
        'name': name,
        'is_finished': 0,
        'image_path': imagePath,
      }
    );
  }

  Future<List<Map<String, dynamic>>> getAllCollections() async {
    final db = await database;
    return await db.query('collection');
  }

  Future<List<Map<String, dynamic>>> getAllTodoLists(int collectionId) async {
    final db = await database;
    
    // We use a LEFT JOIN so that if a list somehow doesn't have a color yet, 
    // it still shows up in your UI.
    return await db.rawQuery('''
      SELECT 
        todo_lists.*, 
        colors.hex_value, 
        colors.name AS color_name
      FROM todo_lists
      LEFT JOIN colors ON todo_lists.id = colors.list_id
      WHERE todo_lists.collection_id = ?
    ''', [collectionId]);
  }

  Future<List<Map<String, dynamic>>> getTasks(int listId) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'list_id = ?',
      whereArgs: [listId],
    );
  }

  Future<void> updateListName(int id, String name) async {
    final db = await database;
    await db.update(
      'todo_lists',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<void> updateCollectionName(int id, String name) async {
    final db = await database;
    await db.update(
      'collection',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id]
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

  Future<void> updateTaskName(int id, String name) async {
    final db = await database;
    await db.update(
      'tasks', 
      {'name': name},
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<void> updateTaskImage(int id, String? imagePath) async {
    final db = await database;
    await db.update(
      'tasks', 
      {'image_path': imagePath},
      where: 'id = ?',
      whereArgs: [id]
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

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateListImage(int id, String? imagePath) async {
    final db = await database;
    await db.update(
      'todo_lists', 
      {'image_path': imagePath},
      where: 'id = ?',
      whereArgs: [id]
    );
  }
}
