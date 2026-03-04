import 'package:first_project/screens/home_screen/collection_controller.dart';
import 'package:flutter/material.dart';
import 'package:first_project/model/app_model.dart';
import 'package:first_project/widgets/cards/lists/list_card.dart';
import 'package:first_project/widgets/cards/lists/add_list_card.dart';
import 'package:provider/provider.dart';

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
    final appController = context.watch<AppModel>();
    final collectionController = context.watch<CollectionController>();

    final allLists = appController.lists.values.expand((list) => list).toList();
    final processedLists = collectionController.getProcessedLists(allLists);
    final displayLists = processedLists.where((l) => l.collectionId == collectionId).toList();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        // Add 1 for the "Add List" card
        itemCount: displayLists.length + 1,
        itemBuilder: (context, index) {
          // If we are at the last index, show the Add button
          if (index == displayLists.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AddListCard(onTap: () => onAddList(collectionId)),
            );
          }

          // Grab the list at this index from the processed (filtered) list
          final list = displayLists[index];          

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