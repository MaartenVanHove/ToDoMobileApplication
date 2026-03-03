import 'package:first_project/models/task.dart';
import 'package:first_project/model/app_model.dart';
import 'package:first_project/screens/list_screen/list_controller.dart';
import 'package:first_project/widgets/cards/tasks/completed_card.dart'; // Ensure correct import
import 'package:first_project/widgets/dialogs/change_task_name_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskCompletedListView extends StatelessWidget {
  final List<Task> tasks;
  final int listId;

  const TaskCompletedListView({
    super.key,
    required this.tasks,
    required this.listId,
  });

  @override
  Widget build(BuildContext context) {
    final listController = context.watch<ListController>();
    final appState = context.read<AppModel>();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.startToEnd,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            color: const Color.fromARGB(255, 76, 78, 175),
            child: const Icon(Icons.undo, color: Colors.white),
          ),
          onDismissed: (_) => appState.toggleTaskFinished(task),
          child: FinishedCard(
            cardName: task.name,
            imagePath: task.imagePath,
            index: index,
            isEditMode: listController.isEditMode,
            isSelected: listController.selectedTaskIds.contains(task.id),
            
            // --- UI State Actions (via Controller) ---
            onTapSelect: () {
              if (!listController.isEditMode) return;
              listController.toggleSelection(task.id);
            },
            onPressedEdit: () => listController.activateEditWithTask(task.id),

            // --- Data Actions (via AppState) ---
            onTapUpdateName: () async {
              final newName = await showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (_) => ChangeNameDialog(
                  title: "Change '${task.name}' name",
                ),
              );

              if (newName != null && newName.trim().isNotEmpty) {
                appState.updateTaskName(task, newName.trim());
                listController.toggleEditMode(); // Resets UI mode
              }
            },
            onTapInstantDelete: () {
              if (!listController.isEditMode) return;
              appState.deleteTask(listId, task.id);
            },
            onImageChanged: (newPath) {
              appState.updateTaskImage(task, newPath);
            },
            onTextChanged: (newText) {
              appState.updateTaskName(task, newText);
            },
          ),
        );
      },
    );
  }
}