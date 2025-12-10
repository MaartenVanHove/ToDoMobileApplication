// lib/widgets/todo_card.dart
import 'package:flutter/material.dart';

class TodoCard extends StatelessWidget {
  final String cardName;
  final VoidCallback? onTap;

  const TodoCard({
    super.key,
    required this.cardName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            cardName,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
