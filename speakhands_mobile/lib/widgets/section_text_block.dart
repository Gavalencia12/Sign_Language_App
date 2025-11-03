import 'package:flutter/material.dart';
import '../theme/text_styles.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class SectionTextBlock extends StatelessWidget {
  final String title;
  final String content;

  const SectionTextBlock({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Text(
            title,
            style: AppTextStyles.heading6.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textStrong(context),
            ),
          ),

          const SizedBox(height: 4),

          // Contenido de la sección
          Text(
            content,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.text(context).withOpacity(isDark ? 0.85 : 0.9),
              height: 1.4, // mejora la legibilidad
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
