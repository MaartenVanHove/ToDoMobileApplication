import 'package:first_project/models/task.dart';
import 'package:first_project/model/app_model.dart';
import 'package:first_project/features/list_screen/list_controller.dart';
import 'package:first_project/widgets/cards/tasks/todo_card.dart';
import 'package:first_project/widgets/dialogs/input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskListView extends StatelessWidget {
  final List<Task> tasks;
  final int listId;

  const TaskListView({super.key, required this.tasks, required this.listId});

  @override
  Widget build(BuildContext context) {
    final listController = context.watch<ListController>();
    final appController = context.read<AppModel>();

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) newIndex -= 1;

        final List<Task> items = List.from(tasks);
        final movedTask = items.removeAt(oldIndex);
        items.insert(newIndex, movedTask);

        appController.updateTaskOrder(listId, items);
      },
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Dismissible(
          key: ValueKey(task.id),
          direction: listController.isEditMode
              ? DismissDirection.none
              : DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: const Color.fromARGB(255, 60, 244, 54),
            child: const Icon(Icons.check, color: Colors.white),
          ),
          onDismissed: (_) => appController.toggleTaskFinished(
            task,
            listController.getFinishedTasks(appController, listId).length,
            listController.getTodoTasks(appController, listId).length,
          ),
          child: TodoCard(
            cardName: task.name,
            imagePath: task.imagePath,
            index: index,
            isEditMode: listController.isEditMode,
            isSelected: listController.selectedTaskIds.contains(task.id),

            onTapSelect: () => listController.toggleSelection(task.id),

            onPressedEdit: () => listController.activateEditWithTask(task.id),

            onTapUpdateName: () async {
              final newName = await showDialog<String>(
                context: context,
                builder: (_) =>
                    InputDialog(title: "Change '${task.name}' name"),
              );
              if (newName != null && newName.trim().isNotEmpty) {
                appController.updateTaskName(task, newName.trim());
                listController
                    .toggleEditMode(); // Closes edit mode after change
              }
            },

            onTapInstantDelete: () => appController.deleteTask(listId, task.id),

            onImageChanged: (newPath) =>
                appController.updateTaskImage(task, newPath),
            onTextChanged: (newText) =>
                appController.updateTaskName(task, newText),
          ),
        );
      },
    );
  }
}
