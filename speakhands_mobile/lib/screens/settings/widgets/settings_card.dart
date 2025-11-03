import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// A reusable card widget used in the Settings screen (or similar sections)
// to group related settings or options together.
// Provides a consistent layout, border style, and adaptive theme colors.
class SettingsCard extends StatelessWidget {
  // The list of child widgets displayed inside the card.
  // Typically a combination of `ListTile`s or custom setting rows.
  final List<Widget> children;

  // If not provided, the widget automatically adapts to the
  // current app theme using [AppColors.surface].
  final Color? color;

  const SettingsCard({required this.children, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    // Choose background based on the theme or custom input
    final Color backgroundColor = color ?? AppColors.surface(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.text(context).withOpacity(0.1),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(children: children),
      ),
    );
  }
}
