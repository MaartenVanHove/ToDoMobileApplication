import 'package:first_project/screens/list/widgets/edit_action_bar.dart';
import 'package:first_project/screens/list/widgets/list_tool_bar.dart';
import 'package:first_project/screens/list/widgets/task_completedlist_section.dart';
import 'package:first_project/screens/list/widgets/task_input_field.dart';
import 'package:first_project/screens/list/widgets/task_todolist_section.dart';

import 'package:first_project/widgets/dialogs/change_task_name_dialog.dart';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    // Laden van taken blijft hetzelfde
    Future.microtask(() {
      context.read<MyAppState>().loadTasks(widget.listId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListController(),
      child: Consumer2<MyAppState, ListController>(
        builder: (context, appState, listController, child) {
          final allTasks = appState.tasks[widget.listId] ?? [];
          final todoTasks = allTasks.where((task) => !task.isFinished).toList();
          final finishedTasks = allTasks.where((task) => task.isFinished).toList();
          final list = appState.getListById(widget.listId);

          return Scaffold(
            appBar: _buildTitle(list?.name ?? widget.listName, appState),
            body: SafeArea(
              child: Column(
                children: [
                  ListToolBar(),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (allTasks.isEmpty)
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

                  listController.isEditMode 
                      ? EditActionBar(listId: widget.listId)
                      : TaskInputField(listId: widget.listId),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // TODO: dit kan nog verbeterd worden.
  AppBar _buildTitle(String title, MyAppState appState) {
     return AppBar(
      backgroundColor: const Color(0xFF0A0F1F),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 32)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white70, size: 28),
          onPressed: () async {
            final newName = await showDialog<String>(
              context: context,
              barrierDismissible: false,
              builder: (_) => ChangeNameDialog(title: "Change '$title' title"),
            );

            if (newName != null && newName.trim().isNotEmpty) {
              final list = appState.getListById(widget.listId);
              if (list != null) {
                appState.updateListName(list, newName.trim());
              }
            }
          },
        ),
      ],
    );
  }
}