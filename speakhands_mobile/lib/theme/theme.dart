import 'package:flutter/material.dart';

class AppTheme {
  // Light colors (pastel)
  static const Color lightPrimary = Color(0xFF44CBCC);
  static const Color lightSecondary = Color(0xFFAEC6CF);
  static const Color lightAccent = Color(0xFFA0E7E5);
  static const Color lightBackground = Color(0xFFEFF3FF);
  static const Color lightText = Color(0xFF2F3A4A);

  // Dark colors
  static const Color darkPrimary = Color(0xFF5C8DAD);
  static const Color darkSecondary = Color(0xFF6D9DC5);
  static const Color darkAccent = Color(0xFF7FBEEB);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkText = Color(0xFFE8F0FE);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightPrimary,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightText, fontSize: 16),
      bodyMedium: TextStyle(color: lightText),
      titleLarge: TextStyle(color: lightText, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: lightPrimary,
      unselectedItemColor: lightSecondary,
      backgroundColor: lightBackground,
    ),
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightSecondary,
      surface: lightBackground,
      onPrimary: Colors.white,
      onSurface: lightText,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkPrimary,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkText, fontSize: 16),
      bodyMedium: TextStyle(color: darkText),
      titleLarge: TextStyle(color: darkText, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: darkAccent,
      unselectedItemColor: darkSecondary,
      backgroundColor: darkBackground,
    ),
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      surface: darkBackground,
      onPrimary: Colors.white,
      onSurface: darkText,
    ),
  );
}
