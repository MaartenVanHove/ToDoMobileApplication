import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_project/providers/app_state.dart';
import 'package:first_project/screens/list/list_controller.dart';

class ListScreenTitle extends StatelessWidget implements PreferredSizeWidget {
  final int listId;
  final String title;

  const ListScreenTitle({
    super.key,
    required this.listId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.read<MyAppState>();
    final listController = context.watch<ListController>();

    return AppBar(
      backgroundColor: const Color(0xFF0A0F1F),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 32,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white70, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }

  // AppBar requires a preferred size
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}