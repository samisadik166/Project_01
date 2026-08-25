import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// COLOR PALETTE — single source of truth for the whole app
// ---------------------------------------------------------------------------
class AppColors {
  static const pink = Color(0xFFFF6B9D);
  static const yellow = Color(0xFFFFC93C);
  static const teal = Color(0xFF4EE0C1);
  static const purple = Color(0xFF9B7BFF);
  static const cream = Color(0xFFFFF8E7);
  static const textDark = Color(0xFF3A3A3A);
  static const textGrey = Color(0xFF6B6B6B);
}

// ---------------------------------------------------------------------------
// APP THEME — every screen pulls colors/fonts/shapes from here instead of
// hardcoding Color(0x...) on individual widgets
// ---------------------------------------------------------------------------
class AppTheme {
  static ThemeData lightTheme() {
    // Baloo 2 is a rounded, playful Google Font — good fit for a kids app.
    final baseTextTheme = GoogleFonts.baloo2TextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,

      // Material 3 derives a full, harmonious palette (primary, secondary,
      // surface tones, etc.) from these seed colors, so you don't have to
      // hand-pick every shade yourself.
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
          color: AppColors.textDark,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.textDark),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textGrey,
        ),
      ),

      // Rounded, chunky buttons — easier to tap for small fingers, and
      // reads as "friendly" rather than "sharp corporate corner".
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

      // Rounded, filled, soft-shadow text fields — matches the _KidTextField
      // style already used on the login/signup pages, now centralized.
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
        labelStyle: GoogleFonts.baloo2(color: AppColors.textGrey),
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
