// lib/screens/list/todo_screen.dart
import 'package:first_project/widgets/dialogs/change_task_name_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:first_project/providers/app_state.dart';
import 'package:first_project/models/task.dart';
import 'package:first_project/widgets/cards/tasks/todo_card.dart';
import 'package:first_project/widgets/cards/tasks/completed_card.dart';

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

    return Scaffold(
      appBar: _buildTitle(list?.name ?? '', appState),
      body: SafeArea(
        child: Column(
          children: [
            if(todoTasks.isNotEmpty || finishedTasks.isNotEmpty)
              _buildEditIcon(),
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
              _buildInputField(),
            if(!isEditMode)
              _buildAddButton(appState),
          ],
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


  Widget _buildEditIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        TextButton.icon(
          icon: Icon(
            Icons.edit, 
            color: isEditMode ? Colors.white : Color(0xFF9BB3D1), 
            size: 24
          ),
          label: Text(
            "EDIT",
            style: TextStyle(
              color: isEditMode ? Colors.white : Color(0xFF9BB3D1),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            _toggleEditMode();
          },
        ),
      ],
    );
  }

  void _toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
      if(!isEditMode) _resetEditMode();
    });
  }

  void _resetEditMode() {
    selectedTaskIds.clear();
  }

  // ---------------- ADD TASK ----------------

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter new task',
          hintStyle: TextStyle(
            color: Color(0xFF9BB3D1),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(MyAppState appState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              _addNewTask(appState, name);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6290EB),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Add",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
  
  void _addNewTask(MyAppState appState, String name) {
    appState.addTask(widget.listId, name);
    controller.clear();
  }

  // ---------------- TASKS ----------------

  Widget _buildTodoTasks(MyAppState appState, List<Task> tasks) {
    return ReorderableListView.builder(
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
              }
            },
            onTapInstantDelete: () {
              if(!isEditMode) return;

              setState(() {
                appState.deleteTask(widget.listId, task.id);
              });
            },
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
              }
            },
             onTapInstantDelete: () {
              if(!isEditMode) return;

              setState(() {
                appState.deleteTask(widget.listId, task.id);
              });
            },
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
                        isEditMode = false;
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
                  isEditMode = false;
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