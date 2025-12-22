// lib/screens/add_screens/task/add_new_tasks_screen.dart
import 'package:first_project/providers/app_state.dart';
import 'package:first_project/models/task.dart';
import 'package:first_project/widgets/todo_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNewTasksScreen extends StatefulWidget {
  final int listId;
  final String listName;

  const AddNewTasksScreen({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<AddNewTasksScreen> createState() => _AddNewTasksScreenState();
}

class _AddNewTasksScreenState extends State<AddNewTasksScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ Load tasks ONCE
    Future.microtask(() {
      context.read<MyAppState>().loadTasks(widget.listId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final List<Task> currentTasks =
        appState.tasks[widget.listId] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Add tasks to "${widget.listName}"'),
        backgroundColor: const Color(0xFF3A7AFE),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildInputField(),
              const SizedBox(height: 12),
              _buildAddButton(appState),
              const SizedBox(height: 16),
              Expanded(child: _buildTaskList(currentTasks, appState)),
              const SizedBox(height: 16),
              _buildCompleteButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI ----------------

  TextField _buildInputField() {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: "Enter task name",
        border: OutlineInputBorder(),
      ),
    );
  }

  SizedBox _buildAddButton(MyAppState appState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _addTask(appState),
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
    );
  }

  Widget _buildTaskList(List<Task> tasks, MyAppState appState) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          "No tasks yet",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            //TODO: appState.deleteTask(widget.listId, task.id);
          },
          child: TodoCard(
            cardName: task.name,
            onTap: () => appState.toggleTaskFinished(task),
          ),
        );
      },
    );
  }

  SizedBox _buildCompleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A7AFE),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Complete",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ---------------- Logic ----------------

  void _addTask(MyAppState appState) {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    appState.addTask(widget.listId, text);
    controller.clear();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
