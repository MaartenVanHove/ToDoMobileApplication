// lib/screens/add_new_tasks_screen.dart
import 'package:first_project/providers/app_state.dart';
import 'package:first_project/widgets/todo_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNewTasksScreen extends StatelessWidget {
  final int listId;
  final String listName;

  AddNewTasksScreen({
    super.key,
    required this.listId,
    required this.listName,
  });

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // Ensure tasks for this list are loaded (loadTasks is safe to call repeatedly)
    appState.loadTasks(listId);

    final currentTasks = appState.tasks[listId] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Add tasks to "$listName"'),
        backgroundColor: const Color(0xFF3A7AFE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SafeArea(
          child: Column(
            children: [
              _buildInputField(),
              const SizedBox(height: 12.0),
              _buildAddButton(appState),
              const SizedBox(height: 16.0),
              Expanded(child: _buildTodoListView(appState, currentTasks)),
              const SizedBox(height: 16.0),
              _buildCompleteButton(context),
            ],
          ),
        ),
      ),
    );
  }

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
        onPressed: () {
          _addButtonPressed(appState);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 98, 144, 235),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
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

  Widget _buildTodoListView(MyAppState appState, List currentTasks) {
    return ListView.builder(
      itemCount: currentTasks.length,
      itemBuilder: (context, index) {
        final task = currentTasks[index];
        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) async {
            // If you'd like to delete from DB, implement deleteTask in DatabaseServices and call here.
            await appState.deleteTask(listId, task.id);
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
          // Return to the main menu (pop back to first route)
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A7AFE),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
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

  void _addButtonPressed(MyAppState appState) {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    appState.addTask(listId, text);
    controller.clear();
  }
}
