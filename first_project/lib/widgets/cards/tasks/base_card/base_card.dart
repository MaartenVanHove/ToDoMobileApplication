import 'dart:io';
import 'package:first_project/model/app_model.dart';
import 'package:first_project/services/media/image_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BaseTaskCard extends StatelessWidget {
  final String title;
  final String? imagePath;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback onTapSelect;
  final VoidCallback onTapUpdateName;
  final VoidCallback onTapInstantDelete;
  final VoidCallback? onPressedEdit;
  final Function(String?) onImageChanged;
  final Function(String) onTextChanged;
  final bool isEditMode;
  final bool isSelected;
  final bool showDragHandle;
  final Color backgroundColor;
  final TextStyle textStyle;

  const BaseTaskCard({
    super.key,
    required this.title,
    this.imagePath,
    required this.index,
    this.onTap,
    required this.onTapSelect,
    required this.onTapUpdateName,
    required this.onTapInstantDelete,
    required this.onImageChanged,
    required this.onTextChanged,
    this.onPressedEdit,
    required this.isEditMode,
    required this.isSelected,
    required this.showDragHandle,
    required this.backgroundColor,
    required this.textStyle,
  });

void _showImagePreview(BuildContext context) {
    // 1. Create local variables to track state changes INSIDE the dialog.
    // This allows the user to see updates without the dialog closing.
    String currentTitle = title;
    String? currentImagePath = imagePath;
    
    // 2. Initialize the controller with the current title.
    final TextEditingController nameController = TextEditingController(text: title);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF162238),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- 🖼️ IMAGE SECTION ---
                            Stack(
                              children: [
                                currentImagePath != null
                                    ? Image.file(
                                        File(currentImagePath!),
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                      )
                                    : Container(
                                        height: 200,
                                        width: double.infinity,
                                        color: Colors.black26,
                                        child: const Icon(Icons.image_not_supported,
                                            size: 50, color: Colors.white24),
                                      ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white, size: 20),
                                      onPressed: () async {
                                        File? newImage = await ImageService.pickImage(
                                            ImageSource.gallery);
                                        if (newImage != null) {
                                          // Update the actual data (Database/Provider)
                                          onImageChanged(newImage.path);
                                          
                                          // Update the local dialog UI
                                          setDialogState(() {
                                            currentImagePath = newImage.path;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // --- 📝 IN-LINE EDITABLE TEXT SECTION ---
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                              child: TextField(
                                controller: nameController,
                                style: textStyle.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                ),
                                maxLines: null,
                                decoration: const InputDecoration(
                                  hintText: "Enter name...",
                                  hintStyle: TextStyle(color: Colors.white24),
                                  border: InputBorder.none,
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blueAccent)),
                                ),
                                onSubmitted: (newValue) {
                                  if (newValue.trim().isNotEmpty && newValue != currentTitle) {
                                    onTextChanged(newValue);
                                    setDialogState(() {
                                      currentTitle = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- 🔘 ACTION BUTTONS ---
                    const Divider(color: Colors.white12, height: 1),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          final finalValue = nameController.text.trim();
                          // Final check: Save the text if it changed and user didn't hit 'enter'
                          if (finalValue.isNotEmpty && finalValue != title) {
                            onTextChanged(finalValue);
                          }
                          // Use dialogContext to pop safely
                          Navigator.pop(dialogContext);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text("Save & Close",
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    // ).then((_) {
    //   // 3. Clean up the controller only AFTER the dialog is fully closed.
    //   nameController.dispose();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dynamicCardHeight = (screenHeight * 0.09).clamp(65.0, 95.0);

    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? Colors.blueAccent : Colors.white24,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isEditMode ? onTapSelect : () => _showImagePreview(context),
        onLongPress: isEditMode == false ? onPressedEdit : null,
        child: Container(
          height: dynamicCardHeight,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              // DYNAMIC IMAGE SECTION
              if (imagePath != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 1, // Forces the image to be a square
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Colors.black26,
                        child: Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 12), // Spacer if no image

              // TEXT SECTION
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle.copyWith(
                      // Optional: make font size slightly responsive
                      fontSize: (dynamicCardHeight * 0.22).clamp(14.0, 18.0),
                    ),
                  ),
                ),
              ),

              // 🖐️ DRAG HANDLE
              if (showDragHandle && !isEditMode)
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.drag_indicator, color: Colors.white70, size: 26),
                  ),
                ),

              // 🗑️ DELETE ICON (Edit Mode)
              if (isEditMode)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    onPressed: onTapInstantDelete,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}