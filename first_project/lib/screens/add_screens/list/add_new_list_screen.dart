import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:first_project/providers/app_state.dart';
import 'package:first_project/screens/list/list_screen.dart';
import 'package:first_project/services/media/image_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
                  _imageFile = await ImageService.pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  _imageFile = await ImageService.pickImage(ImageSource.camera);
                  Navigator.pop(context);
                  setState(() {});
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

  Widget _buildImagePickerSection() {
    return GestureDetector(
      onTap: () => _showPickerOptions(context),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF162238),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_imageFile!, fit: BoxFit.cover),
                    Container(color: Colors.black26), // Slight overlay
                    const Center(
                      child: Icon(Icons.edit, color: Colors.white, size: 40),
                    ),
                  ],
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: Colors.white54, size: 48),
                  SizedBox(height: 12),
                  Text(
                    "Add List Cover Photo",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1F),
        title: const Text('Add List'),
        titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 28),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImagePickerSection(),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Enter list name *",
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF162238),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                _buildNextButton(context, appState),
              ],
            ),
          ),
        ),
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
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("Create List", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _saveNewList(BuildContext context, MyAppState appState) async {
    final input = controller.text.trim();
    if (input.isEmpty) return;

    String? finalImagePath;

    // --- START VEILIG OPSLAAN LOGICA ---
    if (_imageFile != null) {
      try {
        // 1. Zoek de permanente Documents map
        final directory = await getApplicationDocumentsDirectory();
        
        // 2. Maak een unieke bestandsnaam voor de lijst-cover
        final String fileName = "list_cover_${DateTime.now().millisecondsSinceEpoch}${p.extension(_imageFile!.path)}";
        final String newPath = p.join(directory.path, fileName);

        // 3. Kopieer het bestand fysiek naar de veilige map
        final File savedImage = await _imageFile!.copy(newPath);
        finalImagePath = savedImage.path;
        
        debugPrint("List cover veilig opgeslagen: $finalImagePath");
      } catch (e) {
        debugPrint("Fout bij opslaan list cover: $e");
        // Optioneel: als kopiëren faalt, val terug op het tijdelijke pad
        finalImagePath = _imageFile?.path;
      }
    }
    // --- EINDE VEILIG OPSLAAN LOGICA ---

    // Gebruik nu 'finalImagePath' in plaats van '_imageFile?.path'
    final newListId = await appState.createList(
      input, 
      widget.collectionId, 
      finalImagePath
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