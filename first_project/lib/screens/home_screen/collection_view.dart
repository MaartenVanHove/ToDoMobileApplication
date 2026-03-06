import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:first_project/model/app_model.dart';
import 'package:first_project/screens/home_screen/collection_controller.dart';
import 'package:first_project/screens/home_screen/widget_views/filter_bar.dart';
import 'package:first_project/screens/home_screen/widget_views/collection_header.dart';
import 'package:first_project/screens/home_screen/widget_views/collection_list_view.dart';

import 'package:first_project/screens/add_screens/collection/add_new_collection.dart';
import 'package:first_project/screens/add_screens/list/add_new_list_screen.dart';
import 'package:first_project/screens/list_screen/list_view.dart';
import 'package:first_project/widgets/dialogs/input_dialog.dart';
import 'package:first_project/widgets/dialogs/confirm_dialog.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppModel>();
    final collectionController = context.watch<CollectionController>();
    final collections = appController.collections;

    int? _selectedTagId; // In your Screen State

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      appBar: _buildAppBar(),
      
      floatingActionButton: _buildFloatingActionButton(context),
      
      body: SafeArea(
        child: Column(
          children: [
            FilterBar(

            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 100), // Added padding for FAB clearance
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  final col = collections[index];
                  return Column(
                    children: [
                      CollectionHeader(
                        collection: col,
                        onRename: () => _handleRename(context, appController, col),
                        onAddList: () => _navigateToAddList(context, col.id),
                        onDelete: () => _handleDelete(context, appController, col),
                      ),
                      CollectionListView(
                        collectionId: col.id,
                        appState: appController,
                        onNavigateToList: (id, idx) => _navigateToList(context, id, col.name),
                        onAddList: (id) => _navigateToAddList(context, id),
                        onDeleteList: (cId, lId, name) => _handleDeleteList(context, appController, cId, lId, name),
                      ),
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

  // --- UI PIECES (FAB & APPBAR) ---

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToAddCollection(context),
      backgroundColor: const Color(0xFF3A7AFE),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "Collection",
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      // backgroundColor: const Color(0xFF0A0F1F),
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

  // --- LOGIC HANDLERS (Rename, Delete, Navigation) ---

  void _handleRename(BuildContext context, AppModel appState, var collection) async {
    final newName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => InputDialog(
        title: "Change '${collection.name}' title",
      ),
    );
    if (newName != null && newName.trim().isNotEmpty) {
      appState.updateCollectionName(collection, newName);
    }
  }

  void _handleDelete(BuildContext context, AppModel appState, var collection) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog(
        title: "Delete ${collection.name}?",
        message: "This will permanently remove the collection and all its lists.",
        onConfirm: () => appState.deleteCollection(collection.id),
      ),
    );
  }

  void _handleDeleteList(BuildContext context, AppModel appModel, int collectionId, int listId, String listName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog(
        title: "Delete $listName?",
        message: "This will permanently remove the list.",
        onConfirm: () => appModel.deleteList(collectionId, listId),
      ),
    );
  }

  // --- NAVIGATION ---

  void _navigateToAddCollection(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddNewCollectionScreen()));
  }

  void _navigateToAddList(BuildContext context, int collectionId) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddNewListScreen(collectionId: collectionId)));
  }

  void _navigateToList(BuildContext context, int listId, String listName) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ListScreen(listId: listId, listName: listName)));
  }
}