import 'package:flutter/material.dart';
import 'app_colors.dart';

// Centralized text style definitions used throughout the SpeakHands app.
// This class defines a set of reusable and theme-adaptive text styles that ensure
// consistent typography across all screens.

// Each style can be combined with `AppColors` to automatically match
// the current theme (light or dark).
class AppTextStyles {
  // ===== 🌞 LIGHT & DARK STYLES =====
  // Default light/dark mode text.
  static TextStyle lightTextStyle = TextStyle(
    color: AppColors.textLight,
    fontSize: 16,
  );
  static TextStyle darkTextStyle = TextStyle(
    color: AppColors.textDark,
    fontSize: 16,
  );

  // Large title for light/dark mode (bold).
  static TextStyle titleLargeLight = TextStyle(
    color: AppColors.textLight,
    fontWeight: FontWeight.bold,
  );
  static TextStyle titleLargeDark = TextStyle(
    color: AppColors.textDark,
    fontWeight: FontWeight.bold,
  );

  // ===== BASE TYPOGRAPHY =====
  // Section headings, subtitles, or emphasized labels.
  static const TextStyle heading6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // General paragraph and body text.
  static const TextStyle bodyText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Prominent page titles (used in app bars or headers).
  static const textTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );
}
