import 'package:first_project/screens/list/widgets/edit_action_bar.dart';
import 'package:first_project/services/media/image_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'dart:io';

import 'package:first_project/widgets/dialogs/change_task_name_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:first_project/providers/app_state.dart';
import 'package:first_project/models/task.dart';
import 'package:first_project/widgets/cards/tasks/todo_card.dart';
import 'package:first_project/widgets/cards/tasks/completed_card.dart';

import 'package:first_project/screens/list/list_controller.dart';

class ListScreen extends StatefulWidget {
  final int listId;
  final String listName;

  const ListScreen({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final TextEditingController controller = TextEditingController();

  File? _imageFile;

  bool isEditMode = false;

  final Set<int> selectedTaskIds = {};

  @override
  void initState() {
    super.initState();

    // Ensure tasks are loaded once
    Future.microtask(() {
      context.read<MyAppState>().loadTasks(widget.listId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final allTasks = appState.tasks[widget.listId] ?? [];

    final todoTasks = allTasks.where((task) => !task.isFinished).toList();
    final finishedTasks = allTasks.where((task) => task.isFinished).toList();

    final list = appState.getListById(widget.listId);



    return ChangeNotifierProvider(
      create: (_) => ListController(),
    // 2. The 'builder' or 'child' ensures that everything below (like EditActionBar) 
    // can find the controller.
      child: Scaffold(
        appBar: _buildTitle(list?.name ?? '', appState),
        body: SafeArea(
          child: Column(
            children: [
              if(todoTasks.isNotEmpty || finishedTasks.isNotEmpty)
                EditActionBar(),
              // SCROLLABLE CONTENT
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (todoTasks.isEmpty && finishedTasks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "No cards yet! 🎉",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),

                      _buildTodoTasks(appState, todoTasks),
                      _buildFinishedTasks(appState, finishedTasks),
                    ],
                  ),
                ),
              ),

              if(isEditMode) _buildEditActions(appState),
              if(!isEditMode) 
                _buildInputField(appState),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildTitle(String title, MyAppState appState) {
    return AppBar(
      backgroundColor: const Color(0xFF0A0F1F),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 32,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white70, size: 28),
          onPressed: () async {
            final newName = await showDialog<String>(
              context: context,
              barrierDismissible: false,
              builder: (_) => ChangeNameDialog.ChangeNameDialog(
                title: "Change '$title' title",
              ),
            );

            if (newName == null || newName.trim().isEmpty) return;

            final list = appState.getListById(widget.listId);
            if (list != null) {
              appState.updateListName(list, newName.trim());
            }
          },
        ),
      ],
    );
  }

  void _activateEditModeWithSelect(Task task) {
    setState(() {
      isEditMode = true;
      selectedTaskIds.add(task.id);
    });
  }

  void _resetEditMode() {
    selectedTaskIds.clear();
    isEditMode = false;
  }

  // ---------------- ADD TASK ----------------

  Widget _buildInputField(MyAppState appState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1F),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,       
        children: [
          if(_imageFile != null) 
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(_imageFile!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // "Remove" button
                GestureDetector(
                  onTap: () => setState(() => _imageFile = null),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // The Input Bubble
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF162238),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (text) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Enter new Task...',
                      hintStyle: const TextStyle(color: Color(0xFF9BB3D1)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: InputBorder.none, // Removes the standard line
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo_library, color: Color(0xFF9BB3D1)),
                            onPressed: () async => _imageFile = await ImageService.pickImage(ImageSource.gallery),
                          ),
                          if (controller.text.isEmpty)
                            IconButton(
                              icon: const Icon(Icons.camera_alt, color: Color(0xFF9BB3D1)),
                              onPressed: () async => _imageFile = await ImageService.pickImage(ImageSource.camera),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // The Circular Send Button
              _buildAddButton(appState),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(MyAppState appState) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF6290EB),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          Icons.add, // WhatsApp style switch
          color: Colors.white,
        ),
        onPressed: () {
          final name = controller.text.trim();
          if (name.isNotEmpty) {
            _saveNewTask(appState, name);
            setState(() {}); // Refreshes to show camera/mic again
          }
        },
      ),
    );
  }
  
  void _saveNewTask(MyAppState appState, String name) async {
    String? savedPath;

    if (_imageFile != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        
        final String fileName = "task_${DateTime.now().millisecondsSinceEpoch}${p.extension(_imageFile!.path)}";
        final String newPath = p.join(directory.path, fileName);

        final File savedImage = await _imageFile!.copy(newPath);
        savedPath = savedImage.path;
        
        debugPrint("Image saved: $savedPath");
      } catch (e) {
        debugPrint("Error saving image: $e");
      }
    }

    appState.addTask(widget.listId, name, savedPath);

    controller.clear();
    setState(() {
      _imageFile = null;
    });
  }

  // ---------------- TASKS ----------------

  Widget _buildTodoTasks(MyAppState appState, List<Task> tasks) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if(oldIndex < newIndex) {
            newIndex -= 1;
          }

          final movedTask = tasks.removeAt(oldIndex);
          tasks.insert(newIndex, movedTask);

          appState.updateTaskOrder(widget.listId, tasks);
        });
      },
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        
        return Dismissible(
          key: ValueKey(task.id),
          direction: isEditMode
            ? DismissDirection.none
            : DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: const Color.fromARGB(255, 60, 244, 54),
            child: const Icon(Icons.check, color: Colors.white),
          ),
          onDismissed: (_) => appState.toggleTaskFinished(task),
          child: TodoCard(
            cardName: task.name,
            imagePath: task.imagePath != null 
              ? task.imagePath
              : null,
            index: index,
            onTapSelect: () {
              if(!isEditMode) return;

              setState(() {
                if (selectedTaskIds.contains(task.id)) {
                  selectedTaskIds.remove(task.id);
                } else {
                  selectedTaskIds.add(task.id);
                }
              });
            },
            onTapUpdateName: () async {
              final newName = await showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (_) => ChangeNameDialog.ChangeNameDialog(
                  title: "Change '${task.name}' name",
                ),
              );

              if (newName != null && newName.trim().isNotEmpty) {
                appState.updateTaskName(task, newName);
                setState(() {
                        _resetEditMode();
                      });
              }
            },
            onTapInstantDelete: () {
              if(!isEditMode) return;

              setState(() {
                appState.deleteTask(widget.listId, task.id);
              });
            },
            updateImagePath: (newPath) {
              appState.updateImage(task, newPath);
            },
            onPressedEdit: () => _activateEditModeWithSelect(task),
            isEditMode: isEditMode,
            isSelected: selectedTaskIds.contains(task.id),
          ),
        );
      },
    );
  }

  // ---------------- FINISHED TASKS ----------------

  Widget _buildFinishedTasks(MyAppState appState, List<Task> tasks) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.startToEnd,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            color: const Color.fromARGB(255, 76, 78, 175),
            child: const Icon(Icons.undo, color: Colors.white),
          ),
          onDismissed: (_) => appState.toggleTaskFinished(task),
          child: FinishedCard(
            cardName: task.name,
            imagePath: task.imagePath != null 
              ? task.imagePath
              : null,
            index: index,
            onTapSelect: () {
              if(!isEditMode) return;

              setState(() {
                if (selectedTaskIds.contains(task.id)) {
                  selectedTaskIds.remove(task.id);
                } else {
                  selectedTaskIds.add(task.id);
                }
              });
            },
            onTapUpdateName: () async {
              final newName = await showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (_) => ChangeNameDialog.ChangeNameDialog(
                  title: "Change '${task.name}' name",
                ),
              );

              if (newName != null && newName.trim().isNotEmpty) {
                appState.updateTaskName(task, newName);
                setState(() {
                        _resetEditMode();
                      });
              }
            },
             onTapInstantDelete: () {
              if(!isEditMode) return;

              setState(() {
                appState.deleteTask(widget.listId, task.id);
              });
            },
            onImageChanged: (newPath) {
              appState.updateImage(task, newPath);
            },
            onPressedEdit: () => _activateEditModeWithSelect(task),
            isEditMode: isEditMode,
            isSelected: selectedTaskIds.contains(task.id),
          ),
        );
      },
    );
  }

  // ---------------- FINISHED TASKS ----------------

  Widget _buildEditActions(MyAppState appState) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE3392F),
              ),
              onPressed: selectedTaskIds.isEmpty
                  ? null
                  : () {
                      for (final id in selectedTaskIds) {
                        appState.deleteTask(widget.listId, id);
                      }
                      setState(() {
                        _resetEditMode();
                      });
                    },
              child: Text(
                "Delete ${selectedTaskIds.length}",
                style: TextStyle(
                  color: selectedTaskIds.isNotEmpty ? Colors.white : Color(0xFF9BB3D1)
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF162238)
              ),
              onPressed: () {
                setState(() {
                  _resetEditMode();
                });
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.white
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}