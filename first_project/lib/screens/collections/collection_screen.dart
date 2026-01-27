import 'package:first_project/models/collection.dart';
import 'package:first_project/screens/add_screens/collection/add_new_collection.dart';
import 'package:first_project/screens/add_screens/list/add_new_list_screen.dart';
import 'package:first_project/screens/list/list_screen.dart';
import 'package:first_project/widgets/cards/lists/list_card.dart';
import 'package:first_project/widgets/dialogs/change_task_name_dialog.dart';
import 'package:first_project/widgets/dialogs/confirm_dialog.dart';
import 'package:first_project/widgets/cards/lists/add_list_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_project/providers/app_state.dart';

class CollectionsScreen extends StatefulWidget {
  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final List<Collection> collections =
      appState.collections;

    return Scaffold(
      floatingActionButton: _buildFloatingActionButton(context),
      appBar: _buildTitle(),
      body: SafeArea(
        child: ListView.builder(
          itemCount: collections.length,
          itemBuilder: (context, index) {
            final collection = collections[index];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
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
                                builder: (_) => ChangeNameDialog.ChangeNameDialog(
                                  title: "Change '${collection.name}' title",
                                ),
                              );
                              if (newName != null && newName.trim().isNotEmpty) {
                                appState.updateCollectionName(collection, newName);
                              }
                            },
                            icon: const Icon(
                              Icons.drive_file_rename_outline,
                              color: const Color(0xFF9BB3D1),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _navigateToAddListScreen(context, collection.id);
                            },
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: const Color(0xFF9BB3D1),
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
                              color: const Color(0xFF9BB3D1),
                              size: 28,
                            ),
                          ),
                        ]
                      ),
                    ],
                  ),
                ),
                _buildListView(context, appState, collection.id),
              ],
            );
          },
        )
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    MyAppState appState,
    int collectionId,
  ) {
    final todoListsInCollection = appState.lists[collectionId] ?? [];

    return SizedBox(
      height: 180,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        buildDefaultDragHandles: false,
        itemCount: todoListsInCollection.length + 1,
        onReorder: (oldIndex, newIndex) {
          // Block moving the Add card
          if (oldIndex >= todoListsInCollection.length ||
              newIndex > todoListsInCollection.length) {
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
          // ➕ ADD LIST CARD (static, last)
          if (index == todoListsInCollection.length) {
            return Padding(
              key: const ValueKey('add_list_card'),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AddListCard(
                onTap: () =>
                    _navigateToAddListScreen(context, collectionId),
              ),
            );
          }

          final todoList = todoListsInCollection[index];

          return Padding(
            key: ValueKey(todoList.id),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ListCard(
              listName: todoList.name,
              imagePath: todoList.imagePath,
              index: index, // used by ReorderableDragStartListener
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
        title: Text('COLLECTIONS'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 32
        ),
        centerTitle: true
      );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToAddCollectionScreen(context),
      backgroundColor: const Color(0xFF3A7AFE),
      icon: const Icon(
        Icons.add,
        color: Colors.white,
      ),
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
      MaterialPageRoute(
        builder: (_) => AddNewCollectionScreen(),
      )
    );
  }

  void _navigateToAddListScreen(BuildContext context, var collectionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddNewListScreen(collectionId: collectionId,),
      )
    );
  }

  void _navigateToListScreen(BuildContext context, var listId, var listName) {
    Navigator.push(
      context,  
      MaterialPageRoute(
        builder: (_) => ListScreen(listId: listId, listName: listName,),
      )
    );
  }
}