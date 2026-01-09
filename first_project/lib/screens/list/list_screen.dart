// lib/screens/list/todo_screen.dart
import 'package:first_project/widgets/dialogs/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:first_project/providers/app_state.dart';
import 'package:first_project/models/task.dart';
import 'package:first_project/widgets/cards/todo_card.dart';
import 'package:first_project/widgets/cards/completed_card.dart';

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

    return Scaffold(
      appBar: _buildTitle(widget.listName),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white70, size: 24),
                  onPressed: () {
                    // Logic to edit the title
                    print("Edit list");
                  },
                ),
              ],
            ),
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
                    const SizedBox(height: 12),
                    _buildFinishedTasks(appState, finishedTasks),
                  ],
                ),
              ),
            ),

            // ADD TASK UI
            _buildInputField(),
            _buildAddButton(appState),
          ],
        ),
      ),
    );
  }

  AppBar _buildTitle(String title) {
    return AppBar(
      backgroundColor: const Color(0xFF0A0F1F),
      // 1. Keep the title simple so it centers perfectly
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 32,
        ),
      ),
      centerTitle: true,
      
      // 2. Use 'actions' to push the icon to the far right
      actions: [
        IconButton(
          icon: const Icon(
            Icons.menu, color: 
            Colors.white70, 
            size: 28
          ),
          onPressed: () {
            // Logic to edit the title
            print("Open menu");
          },
        ),
        // Optional: Add a small bit of padding so the icon isn't touching the screen edge
        const SizedBox(width: 8), 
      ],
    );
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
          )
        ),
      ),
    );
  }

  Widget _buildAddButton(MyAppState appState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
          direction: DismissDirection.endToStart,
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
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ConfirmDialog(
                  title: "Delete ${task.name}",
                  message:
                      "This action will permanently delete the selected task.",
                  onConfirm: () {
                    appState.deleteTask(task.listId, task.id);
                  },
                ),
              );
            },
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
            onPressed: () => showDialog(
              context: context,
              builder: (_) => ConfirmDialog(
                title: "Delete ${task.name}",
                message:
                    "This action will permanently delete the selected task.",
                onConfirm: () {
                  appState.deleteTask(task.listId, task.id);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
