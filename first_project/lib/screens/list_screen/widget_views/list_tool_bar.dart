import 'package:flutter/material.dart';
import 'package:first_project/screens/list_screen/list_controller.dart';
import 'package:provider/provider.dart';

class ListToolBar extends StatelessWidget {
  
  //TODO: add new functionalities like: searchbar & filter system.

  @override
  Widget build(BuildContext context) {
    final listController = context.watch<ListController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        TextButton.icon(
          icon: Icon(
            Icons.edit, 
            color: listController.isEditMode ? Colors.white : Color(0xFF9BB3D1), 
            size: 24
          ),
          label: Text(
            "EDIT",
            style: TextStyle(
              color: listController.isEditMode ? Colors.white : Color(0xFF9BB3D1),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            listController.toggleEditMode();
          },
        ),
      ],
    );
  }
}