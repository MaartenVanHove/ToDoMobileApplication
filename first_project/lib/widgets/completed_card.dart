// lib/widgets/completed_card.dart
import 'package:flutter/material.dart';

class FinishedCard extends StatelessWidget {
  final String cardName;
  final VoidCallback? onTap;

  const FinishedCard({
    super.key,
    required this.cardName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.grey.shade200,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            cardName,
            style: TextStyle(
              fontSize: 18,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
