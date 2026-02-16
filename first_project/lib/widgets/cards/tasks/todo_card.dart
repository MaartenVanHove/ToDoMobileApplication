import 'package:first_project/widgets/cards/tasks/base_card/base_card.dart';
import 'package:flutter/material.dart';

class TodoCard extends StatelessWidget {
  final String cardName;
  final String? imagePath;
  final int index;
  final VoidCallback onTapSelect;
  final VoidCallback onTapUpdateName;
  final VoidCallback onTapInstantDelete;
  final Function(String?) onImageChanged;
  final Function(String) onTextChanged;
  final VoidCallback? onPressedEdit;
  final bool isEditMode;
  final bool isSelected;

  const TodoCard({
    super.key,
    required this.cardName,
    this.imagePath,
    required this.index,
    required this.onTapSelect,
    required this.onTapUpdateName,
    required this.onTapInstantDelete,
    required this.onImageChanged,
    required this.onTextChanged,
    this.onPressedEdit,
    required this.isEditMode,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BaseTaskCard(
      title: cardName,
      imagePath: imagePath,
      index: index,
      onTapSelect: onTapSelect,
      onTapUpdateName: onTapUpdateName,
      onTapInstantDelete: onTapInstantDelete,
      onImageChanged: onImageChanged,
      onTextChanged: onTextChanged,
      onPressedEdit: onPressedEdit,
      isEditMode: isEditMode,
      isSelected: isSelected,
      showDragHandle: true,
      backgroundColor: const Color(0xFF1E2F4D),
      textStyle: const TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
    );
  }
}

