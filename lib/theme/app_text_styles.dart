import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  // Hero / display
  static TextStyle display = GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -0.5,
  );

  static TextStyle heroSub = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
    letterSpacing: 0.1,
  );

  // Section labels
  static TextStyle sectionTitle = GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.2,
  );

  static TextStyle sectionSub = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  // Card titles
  static TextStyle cardTitle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.1,
  );

  static TextStyle cardMeta = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMid,
  );

  // Pills / chips
  static TextStyle pillActive = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle pillInactive = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textMid,
  );

  // Lesson row
  static TextStyle lessonTitle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static TextStyle lessonMeta = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  // Bottom nav
  static TextStyle navLabel = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 0.2,
  );

  static TextStyle navLabelActive = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.heroDeep,
    letterSpacing: 0.2,
  );
}
