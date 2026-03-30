import 'dart:io';
import 'package:first_project/features/home_screen/collection_controller.dart';
import 'package:first_project/models/task.dart';
import 'package:first_project/widgets/dialogs/input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../model/app_model.dart';
import '../../services/media/image_service.dart';
import 'package:image_picker/image_picker.dart';

class ListController extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();
  File? imageFile;
  bool isEditMode = false;
  bool isEditingTitle = false;
  late TextEditingController titleEditController;
  final Set<int> selectedTaskIds = {};

  // --- Title Modify Logic ---

  void startEditingTitle(String currentTitle) {
    titleEditController = TextEditingController(text: currentTitle);
    isEditingTitle = true;
    notifyListeners();
  }

  void stopEditingTitle(AppModel appController, int listId) {
    final newName = titleEditController.text.trim();
    if (newName.isNotEmpty) {
      final list = appController.getListById(listId);
      if (list != null) {
        appController.updateListName(list, newName);
      }
    }
    isEditingTitle = false;
    notifyListeners();
  }

  // --- Image Logic ---

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImageService.pickImage(source);
    if (pickedFile != null) {
      imageFile = pickedFile;
      notifyListeners();
    }
  }

  void clearImage() {
    imageFile = null;
    notifyListeners();
  }

  Future<void> updateListImage(
    AppModel appController,
    int listId,
    ImageSource source,
  ) async {
    final pickedFile = await ImageService.pickImage(source);
    if (pickedFile != null) {
      final list = appController.getListById(listId);
      if (list != null) {
        appController.updateListImage(list, pickedFile.path);
      }
    }
  }

  // --- Edit Mode Logic ---

  void toggleEditMode() {
    isEditMode = !isEditMode;
    if (!isEditMode) selectedTaskIds.clear();
    notifyListeners();
  }

  void toggleTaskSelection(int taskId) {
    if (selectedTaskIds.contains(taskId)) {
      selectedTaskIds.remove(taskId);
    } else {
      selectedTaskIds.add(taskId);
    }
    notifyListeners();
  }

  void activateEditWithTask(int taskId) {
    isEditMode = true;
    selectedTaskIds.add(taskId);
    notifyListeners();
  }

  void toggleSelection(int taskId) {
    if (selectedTaskIds.contains(taskId)) {
      selectedTaskIds.remove(taskId);
    } else {
      selectedTaskIds.add(taskId);
    }
    notifyListeners(); // This is the new "setState"
  }

  // --- Database Actions ---

  Future<void> saveTask(
    AppModel appController,
    CollectionController collectionController,
    int listId,
  ) async {
    final name = textController.text.trim();
    if (name.isEmpty) return;

    String? savedPath;
    if (imageFile != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            "task_${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile!.path)}";
        final String newPath = p.join(directory.path, fileName);
        final File savedImage = await imageFile!.copy(newPath);
        savedPath = savedImage.path;
      } catch (e) {
        debugPrint("Error saving image: $e");
      }
    }

    appController.addTask(
      listId,
      name,
      savedPath,
      getTodoTasks(appController, listId).length,
    );

    textController.clear();
    imageFile = null;
    notifyListeners();
  }

  List<Task> getTodoTasks(AppModel appController, int listId) {
    final allTasks = appController.tasks[listId] ?? [];
    return allTasks.where((task) => !task.isFinished).toList();
  }

  List<Task> getFinishedTasks(AppModel appController, int listId) {
    final allTasks = appController.tasks[listId] ?? [];
    return allTasks.where((task) => task.isFinished).toList();
  }

  void deleteSelected(AppModel appController, int listId) {
    for (var id in selectedTaskIds) {
      appController.deleteTask(listId, id);
    }
    isEditMode = false;
    selectedTaskIds.clear();
    notifyListeners();
  }

  void addNewTag(BuildContext context, AppModel appState, int listId) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) =>
          InputDialog(title: "Add Tag", hint: "Example: Workout or groceries"),
    );
    if (name != null) {
      int tagId = await appState.createTag(name);
      appState.attachListAndTag(listId, tagId);
    }
  }
}
