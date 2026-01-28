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
    required this.isEditMode,
    required this.isSelected,
    required this.showDragHandle,
    required this.backgroundColor,
    required this.textStyle,
  });

  // Methode om de grote weergave te tonen
  void _showImagePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF162238),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TITLE
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: textStyle.copyWith(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none, // Voorkom doorgestreepte tekst bij voltooide taken
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // BIG IMAGE
            Flexible(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: imagePath != null
                    ? Image.file(
                        File(imagePath!),
                        width: double.infinity,
                        fit: BoxFit.contain,
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.black26,
                        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.white24),
                      ),
              ),
            ),
            
            // CLOSE BUTTONN
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Color(0xFF9BB3D1))),
            ),
          ],
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
        // Als we in EditMode zijn selecteren we, anders openen we de preview
        onTap: isEditMode ? null : () => _showImagePreview(context),
        child: Row(
          children: [
            // IMAGE THUMBNAIL
            Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 56,
                  height: 56,
                  color: Colors.black26,
                  child: imagePath != null
                      ? Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF9BB3D1),
                          size: 28,
                        ),
                ),
              ),
            ),

            // LEFT ACTIONS (EDIT MODE)
            if (isEditMode)
              Row(
                children: [
                  IconButton(
                    onPressed: onTapSelect,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: Colors.white,
                    ),
                  ),
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

            // TITLE
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

            // ☰ DRAG HANDLE (Alleen zichtbaar in normale modus)
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

            // 🗑 DELETE (EDIT MODE)
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