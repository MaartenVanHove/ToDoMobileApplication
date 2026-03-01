import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_project/screens/list/list_controller.dart';
import 'package:first_project/providers/app_controller.dart';

class EditActionBar extends StatelessWidget {
  final int listId;

  const EditActionBar({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    final listController = context.watch<ListController>();
    final appState = context.read<AppController>();

    final bool hasSelection = listController.selectedTaskIds.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      // Background color matches your theme
      color: const Color(0xFF0A0F1F), 
      child: Row(
        children: [
          // --- DELETE BUTTON ---
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE3392F),
                // Disable button if nothing is selected
                disabledBackgroundColor: const Color(0xFF162238), 
              ),
              onPressed: !hasSelection
                  ? null
                  : () {
                      // Perform the bulk delete
                      for (final id in listController.selectedTaskIds) {
                        appState.deleteTask(listId, id);
                      }
                      // Tell controller to turn off edit mode and clear IDs
                      listController.toggleEditMode(); 
                    },
              child: Text(
                "Delete ${listController.selectedTaskIds.length}",
                style: TextStyle(
                  color: hasSelection ? Colors.white : const Color(0xFF9BB3D1),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // --- CANCEL BUTTON ---
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF162238),
              ),
              onPressed: () {
                // Just turn off edit mode
                listController.toggleEditMode();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}