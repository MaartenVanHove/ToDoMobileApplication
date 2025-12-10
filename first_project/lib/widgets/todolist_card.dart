// lib/widgets/todolist_card.dart
import 'package:flutter/material.dart';

class TodolistCard extends StatelessWidget {
  final String cardName;
  final VoidCallback? onTap;

  const TodolistCard({
    super.key,
    required this.cardName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        title: Text(cardName),
        onTap: onTap,
      ),
    );
  }
}
