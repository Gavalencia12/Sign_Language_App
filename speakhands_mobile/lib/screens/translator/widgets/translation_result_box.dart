import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// A stylized widget that displays the translated result
// (for example, a recognized sign language letter or word)
// inside a rounded, themed container.

// This widget is typically used below the camera preview in
// the **translator** or **interpreter** screen to show the
// current translation output.

// Features:
// - Adapts dynamically to light/dark theme colors.
// - Includes a subtle border and drop shadow for visual depth.
// - Centers and formats the recognized text clearly.
class TranslationResultBox extends StatelessWidget {
  // The text to display, usually the translated sign or recognized output.
  final String text;

  const TranslationResultBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    // Dynamic colors depending on the app theme
    final Color backgroundColor = AppColors.surface(context);
    final Color textColor = AppColors.text(context);
    final Color borderColor = AppColors.primary(context).withOpacity(0.2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.text(context).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
