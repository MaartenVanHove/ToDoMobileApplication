// lib/screens/list/todo_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:first_project/providers/app_state.dart';
import 'package:first_project/models/task.dart';
import 'package:first_project/widgets/todo_card.dart';
import 'package:first_project/widgets/completed_card.dart';

class TodoListScreen extends StatefulWidget {
  final int listId;
  final String listName;

  const TodoListScreen({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
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

    final todoTasks = allTasks.where((t) => !t.isFinished).toList();
    final finishedTasks = allTasks.where((t) => t.isFinished).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // TITLE
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                widget.listName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
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
                          "No tasks yet! 🎉",
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

  // ---------------- ADD TASK ----------------

  Padding _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter new task',
        ),
      ),
    );
  }

  Padding _buildAddButton(MyAppState appState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              appState.addTask(widget.listId, name);
              controller.clear();
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

  // ---------------- TODO TASKS ----------------

  Widget _buildTodoTasks(MyAppState appState, List<Task> tasks) {
    return ListView.builder(
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
            color: Colors.red,
            child: const Icon(Icons.check, color: Colors.white),
          ),
          onDismissed: (_) => appState.toggleTaskFinished(task),
          child: TodoCard(
            cardName: task.name,
            onTap: () => appState.toggleTaskFinished(task),
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
            color: Colors.green,
            child: const Icon(Icons.undo, color: Colors.white),
          ),
          onDismissed: (_) => appState.toggleTaskFinished(task),
          child: FinishedCard(
            cardName: task.name,
            onTap: () => appState.toggleTaskFinished(task),
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
