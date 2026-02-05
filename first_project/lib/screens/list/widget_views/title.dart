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
      // 1. Set background to transparent
      backgroundColor: Colors.transparent,
      // 2. Remove the shadow/line under the AppBar
      elevation: 0,
      centerTitle: true,
      // 3. Optional: Add a slight shadow to the text so it's readable over images
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 32,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.black45,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white70, size: 28),
          onPressed: () {
            // Your menu logic here
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}