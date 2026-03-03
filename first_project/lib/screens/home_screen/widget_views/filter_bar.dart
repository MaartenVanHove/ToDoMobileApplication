import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const FilterBar({super.key, required this.searchQuery, required this.onChanged, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF162238), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Search collections/lists...', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none),
            ),
          ),
          if (searchQuery.isNotEmpty)
            IconButton(icon: const Icon(Icons.clear, color: Colors.white54, size: 20), onPressed: onClear),
        ],
      ),
    );
  }
}