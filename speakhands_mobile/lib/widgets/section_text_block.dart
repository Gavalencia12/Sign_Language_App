import 'package:flutter/material.dart';
import '../theme/text_styles.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// A reusable widget for displaying a titled section of text,
// typically used in informational screens such as:
// - Privacy Policy
// - Terms and Conditions
// - Help or FAQ sections
// It ensures consistent typography and spacing across all textual content
// in the application.

// ### Features:
// - Consistent typographic hierarchy (title + paragraph)
// - Theme-aware text colors for dark/light mode
// - Built on shared text styles from [AppTextStyles]
// - Improved readability with justified alignment and line height
class SectionTextBlock extends StatelessWidget {
  // The title displayed above the paragraph.
  final String title;

  // The paragraph or body content of the section.
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
          // === Section Title ===
          Text(
            title,
            style: AppTextStyles.heading6.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textStrong(context),
            ),
          ),

          const SizedBox(height: 4),

          // === Section Content ===
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
