import 'dart:io';

import 'package:first_project/providers/app_state.dart';
import 'package:first_project/screens/list/list_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class TaskInputField extends StatelessWidget {
  final int listId;
  const TaskInputField({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ListController>();
    final appState = context.read<MyAppState>();

    return Container(
      padding: const EdgeInsets.all(8),
      color: const Color(0xFF0A0F1F),
      child: Column(
        children: [
          if (controller.imageFile != null) 
             _ImagePreview(file: controller.imageFile!, onRemove: controller.clearImage),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF162238),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: controller.textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter new Task...',
                      hintStyle: const TextStyle(color: Color(0xFF9BB3D1)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      suffixIcon: _ImageActions(controller: controller),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SendButton(onPressed: () => controller.saveTask(appState, listId)),
            ],
          ),
        ],
      ),
    );
  }
}


class _SendButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SendButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF6290EB),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _ImagePreview({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                image: FileImage(file),
                fit: BoxFit.cover,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
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
    );
  }
}

class _ImageActions extends StatelessWidget {
  final ListController controller;
  const _ImageActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.photo_library, color: Color(0xFF9BB3D1)),
          onPressed: () => controller.pickImage(ImageSource.gallery),
        ),
        // Only show camera icon if there is no text
        if (controller.textController.text.isEmpty)
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Color(0xFF9BB3D1)),
            onPressed: () => controller.pickImage(ImageSource.camera),
          ),
      ],
    );
  }
}