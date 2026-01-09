// lib/screens/add_screens/list/add_new_list_screen.dart
import 'package:first_project/providers/app_state.dart';
import 'package:first_project/screens/list/list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNewListScreen extends StatelessWidget {
  final int collectionId;

  AddNewListScreen({
    super.key,
    required this.collectionId,
  });

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: _buildTitle(),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInputField(),
                const SizedBox(height: 16),
                _buildNextButton(context, appState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- UI ----------------

  AppBar _buildTitle() {
    return AppBar(
        backgroundColor: const Color(0xFF0A0F1F),
        title: Text('Add List'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 32
        ),
        centerTitle: true
      );
  }

  Widget _buildInputField() {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: const InputDecoration(
        labelText: "Enter list name",
        border: OutlineInputBorder(),
        labelStyle: TextStyle(
          color: Color(0xFF162238),
        )
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

  // ---------------- Logic ----------------

  Future<void> _saveNewList(
    BuildContext context,
    MyAppState appState,
  ) async {
    final input = controller.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a list name")),
      );
      return;
    }

    // ✅ Create list inside correct collection
    final newListId = await appState.createList(input, collectionId);

    // Navigate to add tasks
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListScreen(
          listId: newListId,
          listName: input,
        ),
      ),
    );
  }
}
