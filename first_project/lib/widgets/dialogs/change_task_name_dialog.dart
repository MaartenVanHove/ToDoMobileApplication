import 'package:flutter/material.dart';

class ChangeNameDialog extends StatelessWidget {
  final String title;

  ChangeNameDialog.ChangeNameDialog({
    super.key,
    required this.title,
  });

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E2F4D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Enter new name",
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF162238),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3A7AFE),
                  ),
                  onPressed: () {
                    if(_controller.text.isNotEmpty) {
                      Navigator.pop(context, _controller.text); // ✅ RETURN VALUE
                     } 
                  },
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
