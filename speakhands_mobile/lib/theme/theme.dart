import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// The global theme configuration for the SpeakHands app.
// This class centralizes both the *light* and *dark* [ThemeData]
// definitions, ensuring that colors, widgets, and system UI elements
// adapt seamlessly to the user's theme preference.

// Purpose:
// - Provide a consistent and modern color experience.
// - Automatically switch between light and dark modes.
// - Integrate with the custom color palette from [AppColors].
class AppTheme {
  // === LIGHT THEME ===
  // The default theme for bright conditions.
  // Uses soft backgrounds, dark text, and the brand’s light accent colors.
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      background: AppColors.backgroundLight,
      surface: AppColors.surfaceLight,
      error: AppColors.errorLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
    ),
  );

  // === DARK THEME ===
  // The theme optimized for dark environments.
  // Uses darker surfaces with muted text and lighter accent tones.
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      background: AppColors.backgroundDark,
      surface: AppColors.surfaceDark,
      error: AppColors.errorDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryDark,
    ),
  );
}
