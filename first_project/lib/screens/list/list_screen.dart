import 'package:first_project/core/constants/app_strings.dart';
import 'package:first_project/screens/list/widget_views/edit_action_bar.dart';
import 'package:first_project/screens/list/widget_views/list_tool_bar.dart';
import 'package:first_project/screens/list/widget_views/task_completedlist_section.dart';
import 'package:first_project/screens/list/widget_views/task_input_field.dart';
import 'package:first_project/screens/list/widget_views/task_todolist_section.dart';
import 'package:first_project/screens/list/widget_views/title.dart';

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
            appBar: ListScreenTitle(listId: widget.listId, title: list?.name ?? widget.listName),
            body: SafeArea(
              child: Column(
                children: [
                  ListToolBar(),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (allTasks.isEmpty)
                            _buildEmptyList(),

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

  Widget _buildEmptyList() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        AppStrings.get('list_screen', 'empty_state'),
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}