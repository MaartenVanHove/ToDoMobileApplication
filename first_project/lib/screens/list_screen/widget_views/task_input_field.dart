import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:first_project/screens/list_screen/list_controller.dart';
import 'package:first_project/model/app_model.dart';

class TaskInputField extends StatelessWidget {
  final int listId;

  const TaskInputField({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    // .watch ensures the widget rebuilds when text or images change
    final listController = context.watch<ListController>();
    final appState = context.read<AppModel>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Image Preview Section
          if (listController.imageFile != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(listController.imageFile!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => listController.clearImage(),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          
          // 2. Input Row
          Row(
            // Align items to the bottom so the Add button stays down while the field expands
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF162238),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: listController.textController,
                    style: const TextStyle(color: Colors.white),
                    
                    // --- MULTILINE LOGIC ---
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5, // Grow up to 5 lines before scrolling
                    // -----------------------

                    // This ensures the camera icon toggles visibility as you type
                    onChanged: (text) => listController.notifyListeners(), 
                    
                    decoration: InputDecoration(
                      hintText: 'Enter new Task...',
                      hintStyle: const TextStyle(color: Color(0xFF9BB3D1)),
                      contentPadding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                      border: InputBorder.none,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        // Keeps icons at the bottom of the field when it expands
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo_library, color: Color(0xFF9BB3D1)),
                            onPressed: () => listController.pickImage(ImageSource.gallery),
                          ),
                          // Toggle visibility based on text input
                          if (listController.textController.text.isEmpty)
                            IconButton(
                              icon: const Icon(Icons.camera_alt, color: Color(0xFF9BB3D1)),
                              onPressed: () => listController.pickImage(ImageSource.camera),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 3. Add Button
              _buildAddButton(context, listController, appState),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, ListController controller, AppModel appState) {
    return Container(
      // Padding ensures it matches the height profile of a single-line input bar
      margin: const EdgeInsets.only(bottom: 4), 
      decoration: const BoxDecoration(
        color: Color(0xFF3A7AFE),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: () => controller.saveTask(appState, listId),
      ),
    );
  }
}