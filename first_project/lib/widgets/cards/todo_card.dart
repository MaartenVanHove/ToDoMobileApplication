import 'package:flutter/material.dart';

class TodoCard extends StatelessWidget {
  final String cardName;
  final VoidCallback? onPressed;
  final int index;

  const TodoCard({
    super.key,
    required this.cardName,
    required this.index,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E2F4D),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              cardName,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),

          // 👇 DRAG HANDLE ONLY
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.drag_handle,
                color: Colors.white70,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
