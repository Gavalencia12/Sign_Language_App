import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// A reusable widget used to display a section title across the app.
// Typically placed above grouped content (such as lists, cards, or forms),
// this widget provides consistent spacing, typography, and alignment.
class SectionTitle extends StatelessWidget {
  // The main title text displayed for the section.
  final String title;

  // If not provided, it automatically adapts to the app’s current theme.
  final Color? color;

  const SectionTitle({required this.title, super.key, this.color});

  @override
  Widget build(BuildContext context) {
    // Fallback color if no custom color is provided
    final Color accentColor = AppColors.text(context);

    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: accentColor.withOpacity(0.6),
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
