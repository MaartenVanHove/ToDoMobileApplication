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

  List<Tag> tags = [];

  // Standard color palet.
  Map<int, String> colorPalette = {};

  final db = DatabaseServices.instance;

  AppModel() {
    loadTags();
    loadColorPalette();
    loadCollections();
  }

  Future<void> loadColorPalette() async {
    final List<Map<String, dynamic>> maps = await db.getColors();

    colorPalette = {
      for (var item in maps) item['id'] as int: item['hex_value'] as String,
    };

    notifyListeners();
  }

  Color getColorById(int? colorId) {
    final hex = colorPalette[colorId] ?? 'FF162238'; // Default fallback
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> loadTags() async {
    final taggMaps = await db.getAllTags();
    tags = taggMaps.map((t) => Tag.fromMap(t)).toList();
  }

  Future<void> deleteTag(int id) async {
    await db.deleteTag(id);
    tags.removeWhere((tag) => tag.id == id);
    notifyListeners();
  }

  Future<int> createTag(String name) async {
    final cleanName = name.trim();

    final existingTag = tags.where(
      (t) => t.name.toLowerCase() == cleanName.toLowerCase(),
    );

    if (existingTag.isNotEmpty) {
      return existingTag.first.id; // Return the ID of the one we already have
    }

    // If not, save to DB
    final id = await db.addTag(cleanName);

    if (id != -1 && id != 0) {
      tags.add(Tag.Tag(id: id, name: cleanName));
      tags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      notifyListeners();
    }

    return id;
  }

  Future<void> attachListAndTag(int listId, int tagId) async {
    await db.attachListAndTag(listId, tagId);
    final tag = tags.firstWhere((tag) => tag.id == tagId);
    getListById(listId)?.tags.insert(0, tag);

    notifyListeners();
  }

  Future<void> detachTagToList(int listId, int tagId) async {
    await db.detachTagToList(listId, tagId);
    getListById(listId)?.tags.removeWhere((tag) => tag.id == tagId);

    notifyListeners();
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

    List<TodoList> hydratedLists = [];

    for (var map in listMaps) {
      int listId = map['id'];

      // FETCH THE TAGS from the DB for this specific list
      final tagMaps = await db.getTagsFromList(listId);
      final tagsForThisList = tagMaps.map((t) => Tag.fromMap(t)).toList();

      // Create the TodoList with the fetched tags
      final list = TodoList.fromMap(map, tags: tagsForThisList);
      hydratedLists.add(list);

      await loadTasks(listId);
    }

    // 5. Update the state
    lists[collectionId] = hydratedLists;

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
    final taskMaps = await db.getTasks(
      listId,
    ); // Ensure db.getTasks uses ORDER BY position ASC
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

  Future<int> createList(
    String name,
    int collectionId,
    String? imagePath,
    int colorId,
  ) async {
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

  Future<int> addTask(
    int listId,
    String name,
    String? imagePath,
    int position,
  ) async {
    final taskId = await db.addTask(imagePath, listId, name);
    final newTask = Task(
      id: taskId,
      listId: listId,
      name: name,
      isFinished: false,
      imagePath: imagePath,
      position: position,
    );
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

  Future<void> toggleTaskFinished(
    Task task,
    int finishedPosition,
    int regularPosition,
  ) async {
    await db.updateTaskFinished(task.id, !task.isFinished);
    final list = tasks[task.listId]!;
    final index = list.indexWhere((t) => t.id == task.id);
    final position = task.isFinished ? regularPosition : finishedPosition;
    if (index != -1) {
      list[index] = Task(
        id: task.id,
        listId: task.listId,
        name: task.name,
        isFinished: !task.isFinished,
        imagePath: task.imagePath,
        position: position,
      );
      notifyListeners();
    }
  }

  Future<void> updateTaskName(Task task, String name) async {
    db.updateTaskName(task.id, name);
    final list = tasks[task.listId]!;
    final index = list.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      list[index] = Task(
        id: task.id,
        listId: task.listId,
        name: name,
        isFinished: task.isFinished,
        imagePath: task.imagePath,
        position: task.position,
      );
      notifyListeners();
    }
  }

  Future<void> updateListName(TodoList list, String name) async {
    db.updateListName(list.id, name);
    final collection = lists[list.collectionId]!;
    final index = collection.indexWhere((l) => l.id == list.id);
    if (index != -1) {
      collection[index] = TodoList(
        id: list.id,
        collectionId: list.collectionId,
        name: name,
        imagePath: list.imagePath,
        colorId: list.colorId,
        tags: list.tags,
      );
      notifyListeners();
    }
  }

  Future<void> updateCollectionName(Collection collection, String name) async {
    db.updateCollectionName(collection.id, name);
    final index = collections.indexWhere((c) => c.id == collection.id);
    if (index != -1) {
      collections[index] = new Collection(id: collection.id, name: name);
      notifyListeners();
    }
  }

  void updateTaskImage(Task task, String? imagePath) {
    db.updateTaskImage(task.id, imagePath);
    final list = tasks[task.listId]!;
    final index = list.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      list[index] = Task(
        id: task.id,
        listId: task.listId,
        name: task.name,
        isFinished: task.isFinished,
        imagePath: imagePath,
        position: task.position,
      );
      notifyListeners();
    }
  }

  void updateListImage(TodoList list, String? imagePath) {
    db.updateListImage(list.id, imagePath);
    final collection = lists[list.collectionId]!;
    final index = collection.indexWhere((l) => l.id == list.id);
    if (index != -1) {
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

  // Inside AppModel class
  void updateTaskOrder(int listId, List<Task> reorderedTodos) async {
    // 1. Get the finished tasks (we keep them at the bottom, usually)
    final allTasks = tasks[listId] ?? [];
    final finished = allTasks.where((t) => t.isFinished).toList();

    // 2. Combine new order with the finished ones
    final updatedFullList = [...reorderedTodos, ...finished];
    tasks[listId] = updatedFullList;
    notifyListeners();

    // 3. Persist to Database
    // Create a list of IDs in the exact order they appear now
    final taskIds = updatedFullList.map((t) => t.id).toList();
    await db.updateTasksOrder(taskIds);
  }
}
