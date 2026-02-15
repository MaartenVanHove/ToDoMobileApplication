import 'package:first_project/screens/collections/collection_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddCollectionFab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final collectionController = context.watch<CollectionController>();

    return FloatingActionButton.extended(
      onPressed: () => collectionController.navigateToAddCollectionScreen(context),
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
}