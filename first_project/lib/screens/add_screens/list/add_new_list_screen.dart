// lib/screens/add_new_list_screen.dart
import 'package:first_project/providers/app_state.dart';
import 'package:first_project/screens/add_screens/task/add_new_tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNewListScreen extends StatelessWidget {
  AddNewListScreen({super.key});

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTitle(theme),
                const SizedBox(height: 32.0),
                _buildInputField(),
                const SizedBox(height: 16.0),
                _buildNextButton(context, appState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(var theme) {
    return Text(
      "Add New List",
      style: theme.textTheme.headlineSmall!.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
        letterSpacing: 1.3,
      ),
    );
  }

  Widget _buildInputField() {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: "Enter list name",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, MyAppState appState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _saveNewList(context, appState),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A7AFE),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          "Next",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // PAGE LOGIC:

  void _saveNewList(BuildContext context, MyAppState appState) async {
    String input = controller.text.trim();

    if (input.isEmpty) {
      // show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a list name"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Create the list in DB and get its id, then navigate to AddNewTasksScreen 
    final newListId = await appState.createList(input);

    // Navigate to AddNewTasksScreen, passing listId and listName
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewTasksScreen(
          listId: newListId,
          listName: input,
        ),
      ),
    );
  }
}

