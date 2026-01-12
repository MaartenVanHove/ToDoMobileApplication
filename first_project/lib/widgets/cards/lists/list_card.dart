import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final String listName;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final int index;

  const ListCard({
    super.key,
    required this.listName,
    required this.onTap,
    required this.onPressed,
    required this.index
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 200,
        height: 180,
        child: Card(
          color: const Color(0xFF1E2F4D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            
              ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_handle,
                  color: Colors.white70,
                  size: 28,
                ),
              ),

              // 🔲 IMAGE PLACEHOLDER
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Container(
                  width: 150,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B3F66),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Color(0xFF9BB3D1),
                  ),
                ),
              ),

              // 📝 LIST NAME
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  listName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9BB3D1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
