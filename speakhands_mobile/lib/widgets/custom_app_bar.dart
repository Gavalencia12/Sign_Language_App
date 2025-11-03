import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:speakhands_mobile/theme/text_styles.dart';

// A reusable and theme-adaptive top navigation bar
// that displays a screen title alongside the **SpeakHands** brand name.
// It integrates with the global theme using [AppColors] and [AppTextStyles],
// while allowing optional customization of background and text colors.

// ### Features:
// - Dynamic theming (light/dark mode compatible)
// - Optional background and text color overrides
// - Built-in branding: `"SpeakHands"` on the right side
// - Automatically adjusts size to match the standard app bar height
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Main title displayed on the left.
  final String title;

  // Optional background color
  final Color? backgroundColor;

  // Optional color for the title accent
  final Color? titleColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    // === Dynamic color selection based on current theme ===
    final Color bgColor = backgroundColor ?? AppColors.background(context);
    final Color textColor = titleColor ?? AppColors.primary(context);
    final Color accentColor = AppColors.text(context);

    return AppBar(
      elevation: 0,
      backgroundColor: bgColor,
      titleSpacing: 16,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // === Screen Title ===
          Text(
            title.toUpperCase(),
            style: AppTextStyles.textTitle.copyWith(
              color: accentColor,
              letterSpacing: 0.8,
            ),
          ),

          // === SpeakHands Branding ===
          Row(
            children: [
              Text(
                "Speak",
                style: AppTextStyles.textTitle.copyWith(color: textColor),
              ),
              Text(
                "Hands",
                style: AppTextStyles.textTitle.copyWith(color: accentColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Ensures the app bar has the standard Material height.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
