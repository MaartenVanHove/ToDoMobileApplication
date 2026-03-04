import 'package:first_project/models/collection.dart';
import 'package:first_project/models/tag.dart';
import 'package:first_project/models/task.dart';
import 'package:first_project/models/todo_list.dart';
import 'package:first_project/services/db/database_helper.dart';
import 'package:flutter/material.dart';

class AppModel extends ChangeNotifier {
  
  List<Collection> collections = [];
  Map<int, List<TodoList>> lists = {}; // int represent collectionId
  Map<int, List<Task>> tasks = {}; // int represent listId

  List<Tagg> taggs = [];

  // Standard color palet.
  Map<int, String> colorPalette = {};

  final db = DatabaseServices.instance;

  AppModel() {
    loadCollections();
    loadColorPalette();
  }


  Future<void> loadColorPalette() async {
    final db = DatabaseServices.instance;
    // You'll need to add getColors() to your DatabaseServices
    final List<Map<String, dynamic>> maps = await db.getColors(); 
    
    colorPalette = {
      for (var item in maps) item['id'] as int : item['hex_value'] as String
    };

    notifyListeners();
  }

  Color getColorById(int? colorId) {
    final hex = colorPalette[colorId] ?? 'FF162238'; // Default fallback
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> loadTags() async {
    final taggMaps = await db.getAllTags();
    taggs = taggMaps.map((t) => Tagg.fromMap(t)).toList();
  }

  Future<void> loadCollections() async {
    final collectionMaps = await db.getAllCollections();
    collections = collectionMaps.map((e) => Collection.fromMap(e)).toList();

    // Load lists for each collection    
    for (var collection in collections) {
      await loadLists(collection.id);
    }

    notifyListeners();
  }

  Future<void> loadLists(int collectionId) async {
    final listMaps = await db.getAllTodoLists(collectionId);
    print('listMaps: $listMaps'); // Debug print to check the data structure
    lists[collectionId] =
        listMaps.map((e) => TodoList.fromMap(e)).toList();

    // Load tasks for each list in this collection
    for (var list in lists[collectionId]!) {
      await loadTasks(list.id);
    }

    notifyListeners();
  }

  TodoList? getListById(int listId) {
  for (var collectionLists in lists.values) {
    for (var list in collectionLists) {
      if (list.id == listId) return list;
    }
  }
  return null; // not found
}

  Future<void> loadTasks(int listId) async {
    final taskMaps = await db.getTasks(listId);
    tasks[listId] = taskMaps.map((e) => Task.fromMap(e)).toList();
    notifyListeners();
  }

  Future<int> createCollection(String name) async {
    final id = await db.addCollection(name);
    collections.add(Collection(id: id, name: name));
    notifyListeners();
    return id;
  }

  Future<void> deleteCollection(int collectionId) async {
    await db.deleteCollection(collectionId);
    collections.removeWhere((c) => c.id == collectionId);
    lists.remove(collectionId);
    notifyListeners();
  }

  Future<int> createList(String name, int collectionId, String? imagePath, int colorId) async {
    // 1. Save to Database (Ensure DatabaseServices.addTodoList accepts imagePath)
    final id = await db.addTodoList(imagePath, name, collectionId, colorId);
    
    // 2. Create the model instance
    final newList = TodoList(
      id: id, 
      name: name, 
      collectionId: collectionId, 
      imagePath: imagePath,
      colorId: colorId,
    );
    
    // Update local state
    lists.putIfAbsent(collectionId, () => []);
    lists[collectionId]!.insert(0, newList);
    tasks[id] = [];
    
    notifyListeners();
    return id;
  }

  Future<void> deleteList(int collectionId, int listId) async {
    await db.deleteTodoList(listId);
    lists[collectionId]?.removeWhere((list) => list.id == listId);
    tasks.remove(listId);
    notifyListeners();
  }

  Future<int> addTask(int listId, String name, String? imagePath) async {
    final taskId = await db.addTask(imagePath, listId, name);
    final newTask = Task(id: taskId, listId: listId, name: name, isFinished: false, imagePath: imagePath);
    tasks.putIfAbsent(listId, () => []);
    tasks[listId]!.insert(0, newTask);
    notifyListeners();
    return taskId;
  }

  Future<void> deleteTask(int listId, int taskId) async {
    await db.deleteTask(taskId); // Make sure you add this method in DB
    tasks[listId]?.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  Future<void> toggleTaskFinished(Task task) async {
    await db.updateTaskFinished(task.id, !task.isFinished);
    final list = tasks[task.listId]!;
    final index = list.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      list[index] = Task(
        id: task.id,
        listId: task.listId,
        name: task.name,
        isFinished: !task.isFinished,
        imagePath: task.imagePath,
      );
      notifyListeners();
    }
  }

  Future<void> updateTaskName(Task task, String name) async {
    db.updateTaskName(task.id, name);
    final list = tasks[task.listId]!;
    final index = list.indexWhere((t) => t.id == task.id);
    if(index != -1) {
      list[index] = Task(
        id: task.id,
        listId: task.listId,
        name: name,
        isFinished: task.isFinished,
        imagePath: task.imagePath
      );
      notifyListeners();
    }
  }

  Future<void> updateListName(TodoList list, String name) async {
    db.updateListName(list.id, name);
    final collection = lists[list.collectionId]!;
    final index = collection.indexWhere((l) => l.id == list.id);
    if(index != -1) {
      collection[index] = TodoList(
        id: list.id, 
        collectionId: list.collectionId,
        name: name,
        imagePath: list.imagePath,
        colorId: list.colorId, 
      );
      notifyListeners();
    }
  }

  Future<void> updateCollectionName(Collection collection, String name) async {
    db.updateCollectionName(collection.id, name);
    final index = collections.indexWhere((c) => c.id == collection.id);
    if (index != -1) {
      collections[index] = new Collection(
        id: collection.id, 
        name: name
      );
      notifyListeners();
    }
  }

  void updateTaskOrder(int listId, List<Task> reorderedTodos) {
    final all = tasks[listId] ?? [];

    final finished = all.where((t) => t.isFinished).toList();

    tasks[listId] = [
      ...reorderedTodos,
      ...finished,
    ];

    notifyListeners();
  }

  void updateTaskImage(Task task, String? imagePath) {
    db.updateTaskImage(task.id, imagePath);
    final list = tasks[task.listId]!;
    final index = list.indexWhere((t) => t.id == task.id);
    if(index != -1) {
      list[index] = Task(
        id: task.id,
        listId: task.listId,
        name: task.name,
        isFinished: task.isFinished,
        imagePath: imagePath
      );
      notifyListeners();
    }
  }

  void updateListImage(TodoList list, String? imagePath) {
    db.updateListImage(list.id, imagePath);
    final collection = lists[list.collectionId]!;
    final index = collection.indexWhere((l) => l.id == list.id);
    if(index != -1) {
      collection[index] = TodoList(
        id: list.id, 
        collectionId: list.collectionId,
        name: list.name,
        imagePath: imagePath,
        colorId: list.colorId,
      );
      notifyListeners();
    }
  }
}
