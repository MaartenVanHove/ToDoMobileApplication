import 'package:flutter/material.dart';

class AddListCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddListCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 200,
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF18243A), // lighter than real cards
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // ➕ ADD ICON
            Icon(
              Icons.add_circle_outline,
              size: 44,
              color: Color(0xFF9BB3D1),
            ),

            SizedBox(height: 12),

            // 📝 LABEL
            Text(
              "Add list",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF9BB3D1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
