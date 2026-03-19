import 'package:first_project/core/theme/app_theme_colors.dart';
import 'package:first_project/widgets/dialogs/input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_project/model/app_model.dart';
import 'package:first_project/features/home_screen/collection_controller.dart';

class FilterBarList extends StatelessWidget {
  final int listId;

  const FilterBarList({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CollectionController>();
    final appState = context.watch<AppModel>();
    final list = appState.getListById(listId);

    return Column(
      children: [
        // Horizontal Tag Ribbon
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: list!.tags.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                final isAllSelected = controller.selectedTagIds.isEmpty;
                return ActionChip(
                  label: const Text("Tag"),
                  avatar: const Icon(Icons.add, color: Colors.white, size: 18),
                  onPressed: () => _AddNewTag(context, appState, listId),
                  backgroundColor: AppThemeColors.accent,
                  labelStyle: TextStyle(
                    color: isAllSelected ? Colors.white : Colors.white54,
                  ),
                );
              }

              final tag = list.tags[index - 1];

              return InputChip(
                label: Text(tag.name),
                onDeleted: () {
                  appState.detachTagToList(listId, tag.id);
                },
                deleteIcon: const Icon(Icons.close, size: 18),
                deleteIconColor: Colors.white70,
                backgroundColor: const Color(0xFF162238),
                labelStyle: const TextStyle(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                side: BorderSide.none,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _AddNewTag(BuildContext context, AppModel appState, int listId) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) =>
          InputDialog(title: "Add Tag", hint: "Example: Workout or groceries"),
    );
    if (name != null) {
      int tagId = await appState.createTag(name);
      appState.attachListAndTag(listId, tagId);
    }
  }
}
