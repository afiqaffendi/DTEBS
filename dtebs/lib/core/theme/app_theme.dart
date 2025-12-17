import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors - Warm & Appetite Inducing for Restaurant Management
  static const Color primaryColor = Color(0xFFFF6B6B); // Vibrant Coral Red
  static const Color primaryVariant = Color(0xFFFF8E53); // Warm Orange
  static const Color accentColor = Color(0xFFFFAB91); // Light Peach

  static const Color backgroundColor = Color(
    0xFFFFF8F0,
  ); // Soft Cream - warm and elegant
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure White Surface
  static const Color secondaryColor = backgroundColor; // Alias for consistency

  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF4CAF50);

  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Color(0xFF2D3436); // Dark Charcoal Text
  static const Color onSurface = Color(0xFF2D3436);
  static const Color onBackground = Color(0xFF2D3436);

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundColor, Color(0xFFFFEFE0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        onSurface: onSurface,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: secondaryColor,
        foregroundColor: onSecondary, // Dark text
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: onSecondary,
        ),
        iconTheme: const IconThemeData(color: onSecondary),
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: onSecondary,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onSecondary,
        ),
        bodyLarge: GoogleFonts.lato(
          fontSize: 16,
          color: onSecondary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14,
          color: onSecondary.withOpacity(0.8),
          height: 1.5,
        ),
        titleMedium: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSecondary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: TextStyle(color: onSecondary.withOpacity(0.6)),
        prefixIconColor: primaryColor,
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
          elevation: 3,
          shadowColor: primaryColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.lato(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceColor,
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(primaryColor),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSecondary,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        elevation: 4,
      ),
    );
  }
}
