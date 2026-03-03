import 'package:flutter/material.dart';

class AppThemeColors {
  // Primary UI Colors
  static const Color background = Color(0xFF0A0F1F);
  static const Color surface = Color(0xFF162238);
  static const Color accent = Color(0xFF3A7AFE);

  static const Map<String, Color> palette = {
    'Dark': Color(0xFF162238),
    'Blue': Color(0xFF3A7AFE),
    'Pink': Color(0xFFE91E63),
    'Orange': Color(0xFFFF9800),
    'Green': Color(0xFF4CAF50),
    'Purple': Color(0xFF9C27B0),
    'Cyan': Color(0xFF00BCD4),
    'Steel': Color(0xFF607D8B),
    'Omri':Color(0xFFB00020),
  };

  static String colorToHex(Color color) {
    return color.value.toRadixString(16).toUpperCase();
  }
}