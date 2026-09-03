import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme() {
    // Baloo 2
    final baseTextTheme = GoogleFonts.baloo2TextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,

      // Material 3
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.pink,
        primary: AppColors.pink,
        secondary: AppColors.teal,
        tertiary: AppColors.yellow,
        error: const Color(0xFFE5484D),
      ),

      textTheme: baseTextTheme.copyWith(
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.darkGray,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.darkGray),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: Colors.grey.shade600,
        ),
      ),

      // Rounded, chunky buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pink,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          textStyle: GoogleFonts.baloo2(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 4,
        ),
      ),

      // Rounded, filled, soft-shadow text fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        labelStyle: GoogleFonts.baloo2(color: Colors.grey.shade600),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.pink,
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: GoogleFonts.baloo2(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.baloo2(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
