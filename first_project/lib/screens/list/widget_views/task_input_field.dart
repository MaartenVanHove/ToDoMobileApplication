import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:first_project/screens/list/list_controller.dart';
import 'package:first_project/providers/app_state.dart';

class TaskInputField extends StatelessWidget {
  final int listId;

  const TaskInputField({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ListController>();
    final appState = context.read<MyAppState>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: const Color(0xFF0A0F1F),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Image Preview Section
          if (controller.imageFile != null)
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
                        image: FileImage(controller.imageFile!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.clearImage(), // logic moved to controller
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF162238),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: controller.textController, // Use controller's text editor
                    style: const TextStyle(color: Colors.white),
                    // No need for setState on onChanged; Provider handles the rebuild
                    decoration: InputDecoration(
                      hintText: 'Enter new Task...',
                      hintStyle: const TextStyle(color: Color(0xFF9BB3D1)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: InputBorder.none,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo_library, color: Color(0xFF9BB3D1)),
                            onPressed: () => controller.pickImage(ImageSource.gallery),
                          ),
                          // Only show camera if text is empty (WhatsApp style)
                          if (controller.textController.text.isEmpty)
                            IconButton(
                              icon: const Icon(Icons.camera_alt, color: Color(0xFF9BB3D1)),
                              onPressed: () => controller.pickImage(ImageSource.camera),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 3. Add Button
              _buildAddButton(context, controller, appState),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, ListController controller, MyAppState appState) {
    return Container(
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