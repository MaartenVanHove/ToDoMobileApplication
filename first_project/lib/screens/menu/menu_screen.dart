// lib/screens/menu_screen.dart
import 'package:first_project/screens/add_screens/list/add_new_list_screen.dart';
import 'package:first_project/widgets/todolist_card.dart';
import 'package:first_project/providers/app_state.dart';
import 'package:first_project/screens/list/todo_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    int listsLength = appState.todoLists.length;

    var iconSize = 32.0; // double
    var iconColor = Colors.white;
    var addIcon = Icon(Icons.add, color: iconColor, size: iconSize);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToCreateList(context);
        },
        backgroundColor: const Color(0xFF3A7AFE),
        child: addIcon,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: _setTitle(context),
            ),
            Expanded(
              child: listsLength == 0
                  ? const Center(
                      child: Text(
                        "No lists yet..\n Create one! [+]",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500),
                      ),
                    )
                  : _buildTodoList(appState, listsLength),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation:

  void _navigateToTodoList(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TodoListScreen(listIndex: index)),
    );
  }

  void _navigateToCreateList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNewListScreen()),
    );
  }

  // User Interface:

  Text _setTitle(BuildContext context) {
    var title = "My Lists";
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }

  ListView _buildTodoList(MyAppState appState, int listsLength) {
    return ListView.builder(
      itemCount: listsLength,
      itemBuilder: (context, index) {
        final list = appState.todoLists[index];
        return ListTile(
          title: TodolistCard(cardName: list.name),
          onTap: () {
            _navigateToTodoList(context, index);
          },
          onLongPress: () async {
            bool? confirmDelete = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Delete list?"),
                content: const Text("Are you sure you want to delete this list?"),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            );

            if (confirmDelete == true) {
              await appState.deleteList(list.id);
            }
          },
        );
      },
    );
  }
}
