// lib/providers/app_state.dart
import 'package:first_project/models/collection.dart';
import 'package:first_project/models/task.dart';
import 'package:first_project/models/todo_list.dart';
import 'package:first_project/services/db/database_helper.dart';
import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {
  // All collections
  List<Collection> collections = [];

  // Map<collectionId, List<TodoList>>
  Map<int, List<TodoList>> lists = {};

  // Map<listId, List<Task>>
  Map<int, List<Task>> tasks = {};

  final db = DatabaseServices.instance;

  AppController() {
    loadCollections();
  }

  // Load all collections from DB
  Future<void> loadCollections() async {
    final collectionMaps = await db.getAllCollections();
    collections = collectionMaps.map((e) => Collection.fromMap(e)).toList();

    // Load lists for each collection
    for (var collection in collections) {
      await loadLists(collection.id);
    }

    notifyListeners();
  }

  // Load all lists for a given collection
  Future<void> loadLists(int collectionId) async {
    final listMaps = await db.getAllTodoLists(collectionId);
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

  // Load tasks for a given list
  Future<void> loadTasks(int listId) async {
    final taskMaps = await db.getTasks(listId);
    tasks[listId] = taskMaps.map((e) => Task.fromMap(e)).toList();
    notifyListeners();
  }

  // CREATE COLLECTION
  Future<int> createCollection(String name) async {
    final id = await db.addCollection(name);
    collections.add(Collection(id: id, name: name));
    notifyListeners();
    return id;
  }

  // DELETE COLLECTION
  Future<void> deleteCollection(int collectionId) async {
    await db.deleteCollection(collectionId);
    collections.removeWhere((c) => c.id == collectionId);
    lists.remove(collectionId);
    notifyListeners();
  }

  // CREATE LIST inside a collection
  Future<int> createList(String name, int collectionId, String? imagePath) async {
    // 1. Save to Database (Ensure DatabaseServices.addTodoList accepts imagePath)
    final id = await db.addTodoList(imagePath, name, collectionId);
    
    // 2. Create the model instance
    final newList = TodoList(
      id: id, 
      name: name, 
      collectionId: collectionId, 
      imagePath: imagePath, // Make sure your TodoList model has this field
    );
    
    // 3. Update local state
    lists.putIfAbsent(collectionId, () => []);
    lists[collectionId]!.insert(0, newList);
    tasks[id] = [];
    
    notifyListeners();
    return id;
  }

  // DELETE LIST
  Future<void> deleteList(int collectionId, int listId) async {
    await db.deleteTodoList(listId);
    lists[collectionId]?.removeWhere((list) => list.id == listId);
    tasks.remove(listId);
    notifyListeners();
  }

  // CREATE TASK
  Future<int> addTask(int listId, String name, String? imagePath) async {
    final taskId = await db.addTask(imagePath, listId, name);
    final newTask = Task(id: taskId, listId: listId, name: name, isFinished: false, imagePath: imagePath);
    tasks.putIfAbsent(listId, () => []);
    tasks[listId]!.insert(0, newTask);
    notifyListeners();
    return taskId;
  }

  // DELETE TASK
  Future<void> deleteTask(int listId, int taskId) async {
    await db.deleteTask(taskId); // Make sure you add this method in DB
    tasks[listId]?.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  // TOGGLE TASK FINISHED
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

  // UPDATE TASK NAME
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

  // UPDATE LIST NAME
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
      );
      notifyListeners();
    }
  }

    // UPDATE COLLECTION NAME
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
    // TODO: add backend function to update list image.
    final collection = lists[list.collectionId]!;
    final index = collection.indexWhere((l) => l.id == list.id);
    if(index != -1) {
      collection[index] = TodoList(
        id: list.id, 
        collectionId: list.collectionId,
        name: list.name,
        imagePath: imagePath,
      );
      notifyListeners();
    }
  }
}
