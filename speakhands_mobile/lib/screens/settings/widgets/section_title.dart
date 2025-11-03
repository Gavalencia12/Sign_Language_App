import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  /// 🔹 Permite personalizar el color (por defecto usa el color primario del tema)
  final Color? color;

  const SectionTitle({required this.title, super.key, this.color});

  @override
  Widget build(BuildContext context) {
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
