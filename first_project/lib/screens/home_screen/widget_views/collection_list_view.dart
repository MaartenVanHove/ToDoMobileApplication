import 'package:flutter/material.dart';
import 'package:first_project/model/app_model.dart';
import 'package:first_project/widgets/cards/lists/list_card.dart';
import 'package:first_project/widgets/cards/lists/add_list_card.dart';

class CollectionListView extends StatelessWidget {
  final int collectionId;
  final AppModel appState;
  final Function(int, int) onNavigateToList;
  final Function(int) onAddList;
  final Function(int, int, String) onDeleteList;

  const CollectionListView({
    super.key, 
    required this.collectionId, 
    required this.appState,
    required this.onNavigateToList,
    required this.onAddList,
    required this.onDeleteList,
  });

  @override
  Widget build(BuildContext context) {
    final lists = appState.lists[collectionId] ?? [];
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: lists.length + 1,
        itemBuilder: (context, index) {
          if (index == lists.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AddListCard(onTap: () => onAddList(collectionId)),
            );
          }
          final list = lists[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ListCard(
              listName: list.name,
              imagePath: list.imagePath,
              colorId: list.colorId,
              index: index,
              onTap: () => onNavigateToList(list.id, index),
              onPressed: () => onDeleteList(collectionId, list.id, list.name),
            ),
          );
        },
      ),
    );
  }
}