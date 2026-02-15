import 'package:first_project/models/collection.dart';
import 'package:first_project/screens/add_screens/collection/add_new_collection.dart';
import 'package:first_project/screens/add_screens/list/add_new_list_screen.dart';
import 'package:first_project/screens/list/list_screen.dart';
import 'package:first_project/widgets/dialogs/confirm_dialog.dart';
import 'package:flutter/material.dart';

class CollectionController extends ChangeNotifier {
  
  // void deleteCollection(BuildContext context, Collection collection) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => ConfirmDialog(
  //       title: "Delete ${collection.name}?",
  //       message: "This will permanently remove everything inside.",
  //       onConfirm: () => state.deleteCollection(collection.id),
  //     ),
  //   );
  // }


  // --- Navigation ---

    void navigateToAddCollectionScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddNewCollectionScreen(),
      )
    );
  }

  void navigateToAddListScreen(BuildContext context, var collectionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddNewListScreen(collectionId: collectionId,),
      )
    );
  }

  void navigateToListScreen(BuildContext context, var listId, var listName) {
    Navigator.push(
      context,  
      MaterialPageRoute(
        builder: (_) => ListScreen(listId: listId, listName: listName,),
      )
    );
  }

}