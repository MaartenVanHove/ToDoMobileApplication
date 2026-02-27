import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';

import 'package:first_project/providers/app_controller.dart';
import 'package:first_project/screens/list/list_screen.dart';
import 'package:first_project/services/media/image_service.dart';

class AddNewListScreen extends StatefulWidget {
  final int collectionId;

  const AddNewListScreen({
    super.key,
    required this.collectionId,
  });

  @override
  State<AddNewListScreen> createState() => _AddNewListScreenState();
}

class _AddNewListScreenState extends State<AddNewListScreen> {
  final TextEditingController controller = TextEditingController();
  File? _imageFile;

  // 🎨 COLOR STATE: Store the database ID, not the Color object
  // Default to 1 (usually the first ID in SQLite)
  int _selectedColorId = 1;

  // ---------------- IMAGE LOGIC ----------------

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF162238),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Photo Gallery', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  final picked = await ImageService.pickImage(ImageSource.gallery);
                  if (picked != null) setState(() => _imageFile = picked);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  final picked = await ImageService.pickImage(ImageSource.camera);
                  if (picked != null) setState(() => _imageFile = picked);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              if (_imageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.redAccent),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    setState(() => _imageFile = null);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- UI COMPONENTS ----------------

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
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_imageFile!, fit: BoxFit.cover),
                    Container(color: Colors.black38),
                    const Center(child: Icon(Icons.edit, color: Colors.white, size: 40)),
                  ],
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: Colors.white70, size: 48),
                  SizedBox(height: 12),
                  Text(
                    "Add List Cover Photo",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildColorPickerSection() {
    // Use Consumer to listen to the palette from the database
    return Consumer<AppController>(
      builder: (context, appState, child) {
        final paletteEntries = appState.colorPalette.entries.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Card Theme Color",
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 55,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: paletteEntries.length,
                separatorBuilder: (_, __) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                  final entry = paletteEntries[index];
                  final int colorId = entry.key;
                  final String hexValue = entry.value;

                  // Parse the hex string from DB into a Color object
                  final Color color = Color(int.parse(hexValue, radix: 16));
                  final isSelected = _selectedColorId == colorId;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorId = colorId),
                    child: Container(
                      width: 55,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected 
                          ? const Icon(Icons.check, color: Colors.white, size: 24) 
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

  @override
  Widget build(BuildContext context) {
    // Use context.watch to rebuild when colorPalette is loaded/updated
    final appState = context.watch<AppController>();
    
    // Helper to get the actual Color object for previewing UI elements
    final selectedColor = appState.getColorById(_selectedColorId);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1F),
        elevation: 0,
        title: const Text('Create New List'),
        titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              children: [
                _buildImagePickerSection(selectedColor),
                const SizedBox(height: 32),
                _buildColorPickerSection(),
                const SizedBox(height: 32),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    labelText: "List Name",
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF162238),
                    prefixIcon: const Icon(Icons.label_outline, color: Colors.white54),
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
      ),
    );
  }

  Widget _buildCreateButton(Color selectedColor) {
    final appState = context.read<AppController>();
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _saveNewList(context, appState),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedColor,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
          shadowColor: selectedColor.withOpacity(0.5),
        ),
        child: const Text(
          "Create List", 
          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _saveNewList(BuildContext context, AppController appState) async {
    final input = controller.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name for your list")),
      );
      return;
    }

    String? finalImagePath;

    if (_imageFile != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = "list_cover_${DateTime.now().millisecondsSinceEpoch}${p.extension(_imageFile!.path)}";
        final String newPath = p.join(directory.path, fileName);
        await _imageFile!.copy(newPath);
        finalImagePath = newPath;
      } catch (e) {
        debugPrint("Error saving image: $e");
      }
    }

    // Now correctly passing the selected DB ID to create the list
    final newListId = await appState.createList(
      input, 
      widget.collectionId, 
      finalImagePath,
      _selectedColorId, 
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ListScreen(listId: newListId, listName: input),
        ),
      );
    }
  }
}