import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../providers/app_state.dart';
import '../../services/media/image_service.dart';
import 'package:image_picker/image_picker.dart';

class ListController extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();
  File? imageFile;
  bool isEditMode = false;
  final Set<int> selectedTaskIds = {};

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
  Future<void> saveTask(MyAppState appState, int listId) async {
    final name = textController.text.trim();
    if (name.isEmpty) return;

    String? savedPath;
    if (imageFile != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = "task_${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile!.path)}";
        final String newPath = p.join(directory.path, fileName);
        final File savedImage = await imageFile!.copy(newPath);
        savedPath = savedImage.path;
      } catch (e) {
        debugPrint("Error saving image: $e");
      }
    }

    appState.addTask(listId, name, savedPath);
    textController.clear();
    imageFile = null;
    notifyListeners();
  }

  void deleteSelected(MyAppState appState, int listId) {
    for (var id in selectedTaskIds) {
      appState.deleteTask(listId, id);
    }
    isEditMode = false;
    selectedTaskIds.clear();
    notifyListeners();
  }
}