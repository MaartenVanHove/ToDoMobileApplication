import 'package:flutter/material.dart';
import 'package:first_project/widgets/completed_card.dart';
import 'package:first_project/widgets/todo_card.dart';
import 'package:first_project/providers/app_state.dart';
import 'package:provider/provider.dart';

class TodoListScreen extends StatelessWidget {
  final int listIndex;

  TodoListScreen({super.key, required this.listIndex});

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final list = appState.todoLists[listIndex];
    final listId = list.id;

    final allTasks = appState.tasks[listId] ?? [];

    final todoTasks = allTasks.where((t) => !t.isFinished).toList();
    final finishedTasks = allTasks.where((t) => t.isFinished).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // TITLE
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                list.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),

            // SCROLL VIEW
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (todoTasks.isEmpty && finishedTasks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "No tasks yet! 🎉",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),

                    // ACTIVE TASKS
                    _buildTodoList(context, appState, listId, todoTasks),

                    SizedBox(height: 12),

                    // FINISHED TASKS
                    _buildFinishedList(context, appState, listId, finishedTasks),
                  ],
                ),
              ),
            ),

            // ADD TASK UI
            _buildTextField(),
            _buildAddButton(appState, listId),
          ],
        ),
      ),
    );
  }

  // ------------------------
  //     ADD TASK UI
  // ------------------------

  Padding _buildTextField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter new task',
        ),
      ),
    );
  }

  Padding _buildAddButton(MyAppState appState, int listId) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              appState.addTask(listId, name);
              controller.clear();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 98, 144, 235),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            "Add",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------
  //     ACTIVE TASKS
  // ------------------------

  Widget _buildTodoList(BuildContext context, MyAppState appState, int listId, List tasks) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            color: Colors.red,
            child: Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            appState.toggleTaskFinished(task); // Move to finished
          },
          child: TodoCard(
            cardName: task.name,
            onTap: () => appState.toggleTaskFinished(task),
          ),
        );
      },
    );
  }

  // ------------------------
  //     FINISHED TASKS
  // ------------------------

  Widget _buildFinishedList(BuildContext context, MyAppState appState, int listId, List tasks) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.startToEnd,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20),
            color: Colors.green,
            child: Icon(Icons.undo, color: Colors.white),
          ),
          onDismissed: (_) {
            appState.toggleTaskFinished(task); // Move back to todo
          },
          child: FinishedCard(
            cardName: task.name,
            onTap: () => appState.toggleTaskFinished(task),
          ),
        );
      },
    );
  }
}
