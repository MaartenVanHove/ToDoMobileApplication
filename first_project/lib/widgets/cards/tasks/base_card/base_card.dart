import 'dart:io';
import 'package:flutter/material.dart';

class BaseTaskCard extends StatelessWidget {
  final String title;
  final String? imagePath;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback onTapSelect;
  final VoidCallback onTapUpdateName;
  final VoidCallback onTapInstantDelete;
  final VoidCallback? onPressedEdit;
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
    this.onPressedEdit,
    required this.isEditMode,
    required this.isSelected,
    required this.showDragHandle,
    required this.backgroundColor,
    required this.textStyle,
  });

void _showImagePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF162238),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The Scrollable Area
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. IMAGE SECTION WITH EDIT ICON
                      Stack(
                        children: [
                          imagePath != null
                              ? Image.file(
                                  File(imagePath!),
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
                          // Image Edit Button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                onPressed: () {
                                  // Add your image picking logic here
                                  Navigator.pop(context);
                                  // Example: _pickImage(ImageSource.gallery);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 2. TEXT SECTION WITH EDIT ICON
                      Container(
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 30, 40, 20), // Added padding for the icon
                              child: Text(
                                title,
                                style: textStyle.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            // Text Edit Button
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: const Icon(Icons.edit_note, color: Color(0xFF9BB3D1), size: 26),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. ACTION BUTTON
              const Divider(color: Colors.white12, height: 1),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("Close",
                        style: TextStyle(color: Color(0xFF9BB3D1), fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        // Verbetering: In Edit Mode selecteert de hele kaart. In normale mode opent hij de preview.
        onTap: isEditMode 
            ? onTapSelect 
            : () => _showImagePreview(context),
        onLongPress: isEditMode == false
         ? onPressedEdit
         : null,
        child: Row(
          children: [
            // 1. LEFT ACTIONS
            if (isEditMode)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onTapUpdateName,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

            // 2. IMAGE THUMBNAIL
            Padding(
              padding: const EdgeInsets.all(10),
              child: imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                          width: 56,
                          height: 56,
                          color: Colors.black26,
                          child: Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                          )),
                    )
                  : const SizedBox(width: 0, height: 56), // Placeholder om alignment gelijk te houden
            ),

            // 3. TITLE
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
            ),

            // 4. DRAG HANDLE (Rechts)
            if (showDragHandle && !isEditMode)
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.drag_indicator,
                    color: Colors.white70,
                    size: 26,
                  ),
                ),
              ),

            // 5. DELETE (Rechts, alleen in Edit Mode)
            if (isEditMode)
              IconButton(
                onPressed: onTapInstantDelete,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}