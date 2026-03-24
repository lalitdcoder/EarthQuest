import 'package:flutter/material.dart';

abstract class AppColors {
  // Core palette
  static const Color background = Color(0xFFF2E4CC); // Cream/Sand
  static const Color heroDeep   = Color(0xFF3B2A1A); // Deep Earth
  static const Color accent     = Color(0xFFC4935A); // Muted Gold
  static const Color success    = Color(0xFF2E6B4F); // Forest Green

  // Surface tints
  static const Color cardLight  = Color(0xFFFAEEDA); // warm off-white card
  static const Color learnTint  = Color(0xFFE1F5EE); // learn icon bg
  static const Color playTint   = Color(0xFFFAEEDA); // play icon bg
  static const Color actTint    = Color(0xFFEAF3DE); // act icon bg

  // Text
  static const Color textDark   = Color(0xFF1E1206); // near-black
  static const Color textMid    = Color(0xFF6B5040); // warm brown-grey
  static const Color textLight  = Color(0xFFA08060); // muted label

  // Dividers / borders
  static const Color border     = Color(0xFFD9C9B0);
  static const Color borderDark = Color(0xFF7A5A3A);
}
