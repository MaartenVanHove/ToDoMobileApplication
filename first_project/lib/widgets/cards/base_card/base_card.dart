import 'package:flutter/material.dart';

class BaseTaskCard extends StatelessWidget {
  final String title;
  final int index;
  final VoidCallback onTap;
  final bool isEditMode;
  final bool isSelected;
  final bool showDragHandle;
  final Color backgroundColor;
  final TextStyle textStyle;

  const BaseTaskCard({
    super.key,
    required this.title,
    required this.index,
    required this.onTap,
    required this.isEditMode,
    required this.isSelected,
    required this.showDragHandle,
    required this.backgroundColor,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEditMode ? onTap : null,
      child: Card(
        color: backgroundColor,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisAlignment: isEditMode
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
          children: [
            // RADIO BUTTON
            if (isEditMode)
              IconButton(
                onPressed: onTap,
                icon: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: Colors.white,
                ),
              ),

            // TEXT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: textStyle,
                ),
              ),
            ),

            // DRAG HANDLE
            if (showDragHandle && !isEditMode)
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.drag_handle,
                    color: Colors.white70,
                    size: 28,
                  ),
                ),
              ),

            // SPACER TO ALIGN FINISHED CARDS
            if (isEditMode && !showDragHandle)
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}
