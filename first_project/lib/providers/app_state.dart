// lib/providers/app_state.dart
import 'package:first_project/models/collection.dart';
import 'package:first_project/models/task.dart';
import 'package:first_project/models/todo_list.dart';
import 'package:first_project/services/db/database_helper.dart';
import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  // All collections
  List<Collection> collections = [];

  // Map<collectionId, List<TodoList>>
  Map<int, List<TodoList>> todoLists = {};

  // Map<listId, List<Task>>
  Map<int, List<Task>> tasks = {};

  final db = DatabaseServices.instance;

  MyAppState() {
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
    todoLists[collectionId] =
        listMaps.map((e) => TodoList.fromMap(e)).toList();

    // Load tasks for each list in this collection
    for (var list in todoLists[collectionId]!) {
      await loadTasks(list.id);
    }

    notifyListeners();
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
    todoLists.remove(collectionId);
    notifyListeners();
  }

  // CREATE LIST inside a collection
  Future<int> createList(String name, int collectionId) async {
    final id = await db.addTodoList(name, collectionId);
    final newList = TodoList(id: id, name: name, collectionId: collectionId);
    todoLists.putIfAbsent(collectionId, () => []);
    todoLists[collectionId]!.add(newList);
    tasks[id] = [];
    notifyListeners();
    return id;
  }

  // DELETE LIST
  Future<void> deleteList(int collectionId, int listId) async {
    await db.deleteTodoList(listId);
    todoLists[collectionId]?.removeWhere((list) => list.id == listId);
    tasks.remove(listId);
    notifyListeners();
  }

  // CREATE TASK
  Future<int> addTask(int listId, String name) async {
    final taskId = await db.addTask(listId, name);
    final newTask = Task(id: taskId, listId: listId, name: name, isFinished: false);
    tasks.putIfAbsent(listId, () => []);
    tasks[listId]!.add(newTask);
    notifyListeners();
    return taskId;
  }

  // // DELETE TASK
  // Future<void> deleteTask(int listId, int taskId) async {
  //   await db.deleteTask(taskId); // Make sure you add this method in DB
  //   tasks[listId]?.removeWhere((t) => t.id == taskId);
  //   notifyListeners();
  // }

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
      );
      notifyListeners();
    }
  }
}
