import 'package:first_project/model/app_model.dart';
import 'package:first_project/features/home_screen/collection_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNewCollectionScreen extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppModel>();

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
      title: Text('Add Collection'),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 32,
      ),
      centerTitle: true,
    );
  }

  Widget _buildInputField() {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Enter collection name",
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF162238),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, AppModel appState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _saveNewCollection(context, appState),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A7AFE),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Create",
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

  Future<void> _saveNewCollection(
    BuildContext context,
    AppModel appState,
  ) async {
    final input = controller.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a collection name")),
      );
      return;
    }

    // Create list inside correct collection
    await appState.createCollection(input);

    // Navigate to add tasks
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CollectionsScreen()),
    );
  }
}
