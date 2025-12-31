import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:first_project/providers/app_state.dart';
import 'package:first_project/models/todo_list.dart';
import 'package:first_project/screens/add_screens/list/add_new_list_screen.dart';
import 'package:first_project/screens/list/todo_screen.dart';
import 'package:first_project/widgets/cards/todolist_card.dart';

class MenuScreen extends StatelessWidget {
  final int collectionId;
  final String collectionName;

  const MenuScreen({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final List<TodoList> lists =
        appState.todoLists[collectionId] ?? [];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateList(context),
        backgroundColor: const Color(0xFF3A7AFE),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTitle(context),
            Expanded(
              child: lists.isEmpty
                  ? _buildEmptyState()
                  : _buildTodoList(context, appState, lists),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI ----------------

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        collectionName,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No lists yet..\nCreate one! [+]",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTodoList(
    BuildContext context,
    MyAppState appState,
    List<TodoList> lists,
  ) {
    return ListView.builder(
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];

        return ListTile(
          title: TodolistCard(cardName: list.name),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ListScreen(
                  listId: list.id,
                  listName: list.name,
                ),
              ),
            );
          },
          onLongPress: () async {
            final confirmDelete = await _confirmDelete(context);
            if (confirmDelete == true) {
              // await appState.deleteList(list.id);
            }
          },
        );
      },
    );
  }

  // ---------------- Navigation ----------------

  void _navigateToCreateList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddNewListScreen(
          collectionId: collectionId,
        ),
      ),
    );
  }

  // ---------------- Dialog ----------------

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete list?"),
        content: const Text("Are you sure you want to delete this list?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
