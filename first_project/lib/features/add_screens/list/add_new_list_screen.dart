import 'dart:io';
import 'package:first_project/widgets/dialogs/input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:first_project/model/app_model.dart';
import 'package:first_project/features/list_screen/list_view.dart';

class AddNewListScreen extends StatefulWidget {
  final int collectionId;

  const AddNewListScreen({super.key, required this.collectionId});

  @override
  State<AddNewListScreen> createState() => _AddNewListScreenState();
}

class _AddNewListScreenState extends State<AddNewListScreen> {
  final TextEditingController controller = TextEditingController();
  File? _imageFile;
  int _selectedColorId = 1;
  final List<int> _selectedTagIds = [];

  // --- SAVE LOGIC ---

  Future<String?> _saveImage() async {
    if (_imageFile == null) return null;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          "list_cover_${DateTime.now().millisecondsSinceEpoch}${p.extension(_imageFile!.path)}";
      final String newPath = p.join(directory.path, fileName);
      await _imageFile!.copy(newPath);
      return newPath;
    } catch (e) {
      debugPrint("Error saving image: $e");
      return null;
    }
  }

  Future<void> _saveNewList(BuildContext context, AppModel appState) async {
    final input = controller.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name for your list")),
      );
      return;
    }

    String? finalImagePath = await _saveImage();

    // 1. Create list and get ID
    final newListId = await appState.createList(
      input,
      widget.collectionId,
      finalImagePath,
      _selectedColorId,
    );

    // 2. ATTACH TAGS to database junction table
    if (_selectedTagIds.isNotEmpty) {
      for (int tagId in _selectedTagIds) {
        await appState.db.attachListAndTag(newListId, tagId);
      }
    }

    // 3. Force state refresh so tags are hydrated in the model
    await appState.loadLists(widget.collectionId);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ListScreen(listId: newListId, listName: input),
        ),
      );
    }
  }

  // --- UI COMPONENTS ---

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppModel>();
    final selectedColor = appState.getColorById(_selectedColorId);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1F),
        elevation: 0,
        title: const Text('Create New List'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            children: [
              _buildImagePickerSection(selectedColor),
              const SizedBox(height: 32),
              _buildColorPickerSection(),
              const SizedBox(height: 32),
              _buildTagSection(selectedColor),
              const SizedBox(height: 32),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  labelText: "List Name",
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF162238),
                  prefixIcon: const Icon(
                    Icons.label_outline,
                    color: Colors.white54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: selectedColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildCreateButton(selectedColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton(Color selectedColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _saveNewList(context, context.read<AppModel>()),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedColor,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
        ),
        child: const Text(
          "Create List",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerSection(Color themeColor) {
    return GestureDetector(
      onTap: () => _showPickerOptions(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _imageFile != null ? Colors.black : themeColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: Colors.white70, size: 48),
                  Text(
                    "Add List Cover Photo",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildColorPickerSection() {
    return Consumer<AppModel>(
      builder: (context, appState, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Card Theme Color",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 55,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: appState.colorPalette.length,
                separatorBuilder: (_, __) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                  final entry = appState.colorPalette.entries.toList()[index];
                  final color = Color(int.parse(entry.value, radix: 16));
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorId = entry.key),
                    child: Container(
                      width: 55,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColorId == entry.key
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: _selectedColorId == entry.key
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTagSection(Color themeColor) {
    return Consumer<AppModel>(
      builder: (context, appState, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tags",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ...appState.tags.map(
                  (tag) => FilterChip(
                    label: Text(tag.name),
                    selected: _selectedTagIds.contains(tag.id),
                    onSelected: (val) => setState(
                      () => val
                          ? _selectedTagIds.add(tag.id)
                          : _selectedTagIds.remove(tag.id),
                    ),
                    selectedColor: themeColor.withOpacity(0.5),
                  ),
                ),
                ActionChip(
                  label: const Text("New Tag"),
                  onPressed: () => _showCreateTagDialog(appState),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showCreateTagDialog(AppModel appState) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => InputDialog(title: "Create new Tag"),
    );
    if (name != null && name.trim().isNotEmpty) {
      final newId = await appState.createTag(name.trim());
      setState(() => _selectedTagIds.add(newId));
    }
  }

  void _showPickerOptions(BuildContext context) {
    /* Keep your original modal code here */
  }
}
