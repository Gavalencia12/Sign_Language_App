import 'package:flutter/material.dart';
import 'app_colors.dart'; //importación de colores

class AppTheme {

  // tema claro
  static ThemeData lightTheme = ThemeData(
    /* brightness: Brightness.light, */
    primaryColor: AppColors.lightPrimary,
    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightAccent, // Reemplazamos accentColor con secondary
      surface: AppColors.lightBackground, // backgroundColor con background
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: AppColors.lightForebackground,
    ),
    buttonTheme: ButtonThemeData(buttonColor: AppColors.lightPrimary),
  );

  // Tema oscuro
  static ThemeData darkTheme = ThemeData(
    /* brightness: Brightness.dark, */
    primaryColor: AppColors.darkPrimary,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkAccent, // Reemplazamos accentColor con secondary
      surface: AppColors.darkBackground, // backgroundColor con background
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.lightForebackground,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
    ),
    buttonTheme: ButtonThemeData(buttonColor: AppColors.darkAccent),
  );
}
