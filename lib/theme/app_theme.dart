import 'package:flutter/material.dart';


import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF2D2F92);
  static const accent = Color(0xFF4F9DFF);
  static const background = Color(0xFFF7F9FC);
  static const card = Color(0xFFFFFFFF);
  static const titleText = Color(0xFF1F2933);
  static const bodyText = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.poppinsTextTheme(),
    useMaterial3: true,
  );
}

