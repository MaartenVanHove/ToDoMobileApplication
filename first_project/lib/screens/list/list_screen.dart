import 'package:first_project/screens/list/widgets/list_tool_bar.dart';
import 'package:first_project/screens/list/widgets/task_completedlist_section.dart';
import 'package:first_project/screens/list/widgets/task_input_field.dart';
import 'package:first_project/screens/list/widgets/task_todolist_section.dart';
import 'package:first_project/services/media/image_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'dart:io';

import 'package:first_project/widgets/dialogs/change_task_name_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:first_project/providers/app_state.dart';

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
                ListToolBar(),
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

                      TaskListView(tasks: todoTasks, listId: widget.listId),
                      TaskCompletedListView(tasks: finishedTasks, listId: widget.listId),
                    ],
                  ),
                ),
              ),

              if(isEditMode) _buildEditActions(appState),
              if(!isEditMode) 
                TaskInputField(listId: widget.listId),
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
              builder: (_) => ChangeNameDialog(
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

  void _resetEditMode() {
    selectedTaskIds.clear();
    isEditMode = false;
  }

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