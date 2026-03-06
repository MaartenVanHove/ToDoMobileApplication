import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_project/model/app_model.dart';
import 'package:first_project/screens/home_screen/collection_controller.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CollectionController>();
    final appState = context.watch<AppModel>();

    return Column(
      children: [
        // 1. Search Bar
        Container(
          height: 45,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF162238),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white54, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  onChanged: (val) => controller.updateSearch(val),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search collections/lists...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (controller.searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
                  onPressed: () => controller.clearSearch(),
                ),
            ],
          ),
        ),

        // 2. Horizontal Tag Ribbon
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: appState.tags.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                final isAllSelected = controller.selectedTagIds.isEmpty;
                return ChoiceChip(
                  label: const Text("All"),
                  selected: isAllSelected,
                  onSelected: (_) => controller.clearTags(),
                  selectedColor: const Color(0xFF3A7AFE),
                  backgroundColor: const Color(0xFF162238),
                  showCheckmark: false,
                  labelStyle: TextStyle(color: isAllSelected ? Colors.white : Colors.white54),
                );
              }

              final tag = appState.tags[index - 1];
              final isSelected = controller.selectedTagIds.contains(tag.id);

              return ChoiceChip(
                label: Text(tag.name),
                selected: isSelected,
                onSelected: (_) => controller.toggleTagSelection(tag.id),
                selectedColor: const Color(0xFF3A7AFE),
                backgroundColor: const Color(0xFF162238),
                showCheckmark: false,
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}