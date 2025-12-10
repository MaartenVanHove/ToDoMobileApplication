// lib/providers/app_state.dart
import 'package:first_project/models/task.dart';
import 'package:first_project/models/todo_list.dart';
import 'package:first_project/services/db/database_helper.dart';
import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  List<TodoList> todoLists = [];
  Map<int, List<Task>> tasks = {};

  final db = DatabaseServices.instance;

  MyAppState() {
    loadLists();
  }

  Future<void> loadLists() async {
    final listMaps = await db.getAllTodoLists();
    todoLists = listMaps.map((e) => TodoList.fromMap(e)).toList();

    // Load tasks for each list
    for (var list in todoLists) {
      await loadTasks(list.id);
    }

    notifyListeners();
  }

  Future<void> loadTasks(int listId) async {
    final taskMaps = await db.getTasks(listId);
    tasks[listId] = taskMaps.map((e) => Task.fromMap(e)).toList();
    notifyListeners();
  }

  // Create list and return its new id (useful for immediate next-screen creation)
  Future<int> createList(String name) async {
    final id = await db.addTodoList(name);
    todoLists.add(TodoList(id: id, name: name));
    tasks[id] = [];
    notifyListeners();
    return id;
  }

  // Backwards-compatible addList (keeps returning void)
  Future<void> addList(String name) async {
    await createList(name);
  }

  Future<void> deleteList(int listId) async {
    await db.deleteTodoList(listId);
    todoLists.removeWhere((list) => list.id == listId);
    tasks.remove(listId);
    notifyListeners();
  }

  // TASK OPERATIONS
  Future<void> addTask(int listId, String name) async {
    final taskId = await db.addTask(listId, name);
    tasks[listId]!.add(Task(
      id: taskId,
      listId: listId,
      name: name,
      isFinished: false,
    ));
    notifyListeners();
  }

  Future<void> deleteTask(int listId, int taskId) async {
    // If you want a deleteTask db method, add it to DatabaseServices. For now, we can mark it finished or leave it.
    final list = tasks[listId]!;
    list.removeWhere((t) => t.id == taskId);
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
      );
      notifyListeners();
    }
  }
}
