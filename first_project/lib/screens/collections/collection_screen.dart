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
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  // Variable to store the current search input
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppController>();
    final List<Collection> allCollections = appState.collections;
    allCollections.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    // Filtering logic: Only show collections whose names contain the search query
    final List<Collection> filteredCollections = allCollections.where((collection) {
      return collection.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      floatingActionButton: _buildFloatingActionButton(context),
      appBar: _buildTitle(),
      body: SafeArea(
        child: Column(
          children: [
            // 1. FIXED FILTER BAR AT THE TOP
            _buildFilterBar(),

            // TODO: Add filter chips here in the future for more advanced filtering options (e.g., by color, by number of lists, etc.)
            SizedBox(height: 6),  

            // 2. EXPANDED LISTVIEW (The fix for your error)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 100),
                itemCount: filteredCollections.length,
                itemBuilder: (context, index) {
                  final collection = filteredCollections[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // COLLECTION HEADER
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

                      // HORIZONTAL LIST OF TODO LISTS
                      _buildListView(context, appState, collection.id),

                      const SizedBox(height: 32),
                    ],
                  );
                },
              ),
            ),
          ],
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

  Widget _buildFilterBar() {
    return Container(
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
              // onChanged: (value) {
              //   setState(() {
              //     _searchQuery = value; // Updates UI instantly on type
              //   });
              // },
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search collections...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
              onPressed: () {
                setState(() {
                  _searchQuery = "";
                });
              },
            ),
        ],
      ),
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