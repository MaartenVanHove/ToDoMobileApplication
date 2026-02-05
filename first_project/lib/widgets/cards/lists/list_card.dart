import 'dart:io';
import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final String listName;
  final String? imagePath;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final int index;

  const ListCard({
    super.key,
    required this.listName,
    this.imagePath,
    required this.onTap,
    required this.onPressed,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dynamicWidth = screenWidth * 0.44; 
    final dynamicHeight = dynamicWidth * 0.9; 

    return InkWell(
      onTap: onTap,
      onLongPress: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: dynamicWidth,
        height: dynamicHeight,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2F4D),
          borderRadius: BorderRadius.circular(16),
          // 🖼️ THE FULL BACKGROUND IMAGE
          image: imagePath != null
              ? DecorationImage(
                  image: FileImage(File(imagePath!)),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.35),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Stack(
          children: [
            // 📝 LIST NAME (Bottom Center)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  listName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white, // White looks better over images
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 4, color: Colors.black), // Adds a glow for readability
                    ],
                  ),
                ),
              ),
            ),

            // 🖐️ DRAG HANDLE (Top Center)
            Align(
              alignment: Alignment.topCenter,
              child: ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(
                    Icons.drag_handle,
                    color: Colors.white70,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}