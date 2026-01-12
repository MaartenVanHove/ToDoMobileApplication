// lib/widgets/completed_card.dart
import 'package:first_project/widgets/cards/base_card/base_card.dart';
import 'package:flutter/material.dart';

class FinishedCard extends StatelessWidget {
  final String cardName;
  final int index;
  final VoidCallback onTapSelect;
  final VoidCallback onTapUpdateName;
  final VoidCallback onTapInstantDelete;
  final bool isEditMode;
  final bool isSelected;

  const FinishedCard({
    super.key,
    required this.cardName,
    required this.index,
    required this.onTapSelect,
    required this.onTapUpdateName,
    required this.onTapInstantDelete,
    required this.isEditMode,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BaseTaskCard(
      title: cardName,
      index: index,
      onTapSelect: onTapSelect,
      onTapUpdateName: onTapUpdateName,
      onTapInstantDelete: onTapInstantDelete,
      isEditMode: isEditMode,
      isSelected: isSelected,
      showDragHandle: false,
      backgroundColor: const Color(0xFF162238),
      textStyle: TextStyle(
        fontSize: 18,
        decoration: TextDecoration.lineThrough,
        color: Colors.grey.shade700,
      ),
    );
  }
}


