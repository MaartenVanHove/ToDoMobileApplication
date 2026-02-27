import 'package:first_project/models/collection.dart';
import 'package:first_project/providers/app_controller.dart';
import 'package:first_project/screens/add_screens/collection/add_new_collection.dart';
import 'package:first_project/screens/add_screens/list/add_new_list_screen.dart';
import 'package:first_project/screens/list/list_screen.dart';
import 'package:first_project/widgets/cards/lists/list_card.dart';
import 'package:first_project/widgets/dialogs/change_task_name_dialog.dart';
import 'package:first_project/widgets/dialogs/confirm_dialog.dart';
import 'package:first_project/widgets/cards/lists/add_list_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionsScreen extends StatefulWidget {
  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppController>();
    final List<Collection> collections = appState.collections;
    

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F), // Matches your theme
      floatingActionButton: _buildFloatingActionButton(context),
      appBar: _buildTitle(),
      body: SafeArea(
        child: ListView.builder(
          // Adds space at the top of the list and bottom (for FAB clearance)
          padding: const EdgeInsets.only(top: 16, bottom: 100),
          itemCount: collections.length,
          itemBuilder: (context, index) {
            final collection = collections[index];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. COLLECTION HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            collection.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 26,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final newName = await showDialog<String>(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => ChangeNameDialog(
                                  title: "Change '${collection.name}' title",
                                ),
                              );
                              if (newName != null && newName.trim().isNotEmpty) {
                                appState.updateCollectionName(collection, newName);
                              }
                            },
                            icon: const Icon(
                              Icons.drive_file_rename_outline,
                              color: Color(0xFF9BB3D1),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _navigateToAddListScreen(context, collection.id),
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF9BB3D1),
                              size: 28,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => ConfirmDialog(
                                  title: "Delete ${collection.name}?",
                                  message: "This will permanently remove the collection and all its lists.",
                                  onConfirm: () {
                                    appState.deleteCollection(collection.id);
                                  },
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Color(0xFF9BB3D1),
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. HORIZONTAL LIST OF TODO LISTS
                _buildListView(context, appState, collection.id),

                // 3. SPACING BETWEEN COLLECTIONS
                // This creates the visual gap before the next collection starts
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    AppController appState,
    int collectionId,
  ) {
    final todoListsInCollection = appState.lists[collectionId] ?? [];

    return SizedBox(
      height: 180,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        buildDefaultDragHandles: false,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: todoListsInCollection.length + 1,
        onReorder: (oldIndex, newIndex) {
          if (oldIndex >= todoListsInCollection.length || newIndex > todoListsInCollection.length) {
            return;
          }

          if (oldIndex < newIndex) {
            newIndex -= 1;
          }

          setState(() {
            final movedList = todoListsInCollection.removeAt(oldIndex);
            todoListsInCollection.insert(newIndex, movedList);
          });
        },
        itemBuilder: (context, index) {
          // ADD LIST CARD (static, last)
          if (index == todoListsInCollection.length) {
            return Padding(
              key: const ValueKey('add_list_card'),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AddListCard(
                onTap: () => _navigateToAddListScreen(context, collectionId),
              ),
            );
          }

          final todoList = todoListsInCollection[index];
          print('TODOLIST: ${todoList.name}, COLOR ID: ${todoList.colorId}'); // Debug print to check colorId

          return Padding(
            key: ValueKey(todoList.id),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ListCard(
              listName: todoList.name,
              imagePath: todoList.imagePath,
              colorId: todoList.colorId,
              index: index,
              onTap: () => _navigateToListScreen(
                context,
                todoList.id,
                todoList.name,
              ),
              onPressed: () => showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => ConfirmDialog(
                  title: "Delete ${todoList.name}?",
                  message: "This will permanently remove the list.",
                  onConfirm: () {
                    appState.deleteList(collectionId, todoList.id);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildTitle() {
    return AppBar(
      backgroundColor: const Color(0xFF0A0F1F),
      elevation: 0,
      title: const Text('COLLECTIONS'),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 32,
      ),
      centerTitle: true,
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToAddCollectionScreen(context),
      backgroundColor: const Color(0xFF3A7AFE),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "Collection",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _navigateToAddCollectionScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddNewCollectionScreen()),
    );
  }

  void _navigateToAddListScreen(BuildContext context, int collectionId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddNewListScreen(collectionId: collectionId)),
    );
  }

  void _navigateToListScreen(BuildContext context, int listId, String listName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ListScreen(listId: listId, listName: listName)),
    );
  }
}