import 'package:first_project/models/task.dart';
import 'package:first_project/providers/app_state.dart';
import 'package:first_project/screens/list/list_controller.dart';
import 'package:first_project/widgets/cards/tasks/todo_card.dart';
import 'package:first_project/widgets/dialogs/change_task_name_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskListView extends StatelessWidget {
  final List<Task> tasks;
  final int listId;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.listId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ListController>();
    final appState = context.read<MyAppState>();

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      onReorder: (oldIndex, newIndex) {
        // Logic moved to appState or handled locally if list is passed by ref
        if (oldIndex < newIndex) newIndex -= 1;
        final movedTask = tasks.removeAt(oldIndex);
        tasks.insert(newIndex, movedTask);
        appState.updateTaskOrder(listId, tasks);
      },
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Dismissible(
          key: ValueKey(task.id),
          direction: controller.isEditMode ? DismissDirection.none : DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: const Color.fromARGB(255, 60, 244, 54),
            child: const Icon(Icons.check, color: Colors.white),
          ),
          onDismissed: (_) => appState.toggleTaskFinished(task),
          child: TodoCard(
            cardName: task.name,
            imagePath: task.imagePath,
            index: index,
            isEditMode: controller.isEditMode,
            isSelected: controller.selectedTaskIds.contains(task.id),
            
            onTapSelect: () => controller.toggleSelection(task.id),
            
            onPressedEdit: () => controller.activateEditWithTask(task.id),
            
            onTapUpdateName: () async {
              final newName = await showDialog<String>(
                context: context,
                builder: (_) => ChangeNameDialog(title: "Change '${task.name}' name"),
              );
              if (newName != null && newName.trim().isNotEmpty) {
                appState.updateTaskName(task, newName.trim());
                controller.toggleEditMode(); // Closes edit mode after change
              }
            },
            
            onTapInstantDelete: () => appState.deleteTask(listId, task.id),
            
            updateImagePath: (newPath) => appState.updateImage(task, newPath),
          ),
        );
      },
    );
  }
}