import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final String listName;
  final VoidCallback? onTap;
  // final VoiCallback? onPressed;

  const ListCard({
    super.key,
    required this.listName,
    required this.onTap,
    // required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        child: Card(
          color: const Color(0xFF1E2F4D),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              listName,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF9BB3D1)
              ),
            ),
          ),
        ),
      ),
    );
  }
}