import 'package:first_project/models/collection.dart';
import 'package:first_project/screens/add_screens/collection/add_new_collection.dart';
import 'package:first_project/screens/add_screens/list/add_new_list_screen.dart';
import 'package:first_project/screens/list/list_screen.dart';
import 'package:first_project/widgets/cards/lists/list_card.dart';
import 'package:first_project/widgets/dialogs/confirm_dialog.dart';
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
                      Text(
                        collection.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 26,
                        ),
                      ),
                      
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              _navigateToAddListScreen(context, collection.id);
                            },
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                            label: const Text(
                              "List",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
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
                _buildListView(appState, collection.id),
              ],
            );
          },
        )
      ),
    );
  }

  Widget _buildListView(MyAppState appState, int collectionId) {
    final todoListsInCollection = appState.lists[collectionId] ?? [];

    if (todoListsInCollection.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'No lists yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: todoListsInCollection.length,
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }

          setState(() {
            final movedList = todoListsInCollection.removeAt(oldIndex);
            todoListsInCollection.insert(newIndex, movedList);
          });

          // OPTIONAL: persist order to DB
          // appState.updateListOrder(collectionId, todoListsInCollection);
        },
        itemBuilder: (context, index) {
          final todoList = todoListsInCollection[index];

          return Padding(
            key: ValueKey(todoList.id), // ✅ REQUIRED
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ListCard(
              listName: todoList.name,
              onTap: () => _navigateToListScreen(
                context,
                todoList.id,
                todoList.name,
              ),
              index: index,
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