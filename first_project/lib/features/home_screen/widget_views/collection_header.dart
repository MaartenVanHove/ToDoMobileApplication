import 'package:flutter/material.dart';
import 'package:first_project/models/collection.dart';

class CollectionHeader extends StatelessWidget {
  final Collection collection;
  final VoidCallback onRename;
  final VoidCallback onAddList;
  final VoidCallback onDelete;

  const CollectionHeader({super.key, required this.collection, required this.onRename, required this.onAddList, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(collection.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 26)),
              IconButton(onPressed: onRename, icon: const Icon(Icons.drive_file_rename_outline, color: Color(0xFF9BB3D1), size: 24)),
            ],
          ),
          Row(
            children: [
              IconButton(onPressed: onAddList, icon: const Icon(Icons.add_circle_outline, color: Color(0xFF9BB3D1), size: 28)),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_forever, color: Color(0xFF9BB3D1), size: 28)),
            ],
          ),
        ],
      ),
    );
  }
}