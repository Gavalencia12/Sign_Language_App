import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:speakhands_mobile/theme/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

// A reusable widget that displays a titled text section with consistent
// spacing and typography across the app.
//
// Commonly used for displaying Terms & Conditions, Privacy Policy sections,
// or any grouped text-based information.
//
// UPDATE: Added support for markdown-style clickable email links
// inside the section content (e.g., [email](mailto:email@example.com)).
class SectionTextBlock extends StatelessWidget {
  // The title displayed above the paragraph.
  final String title;

  // The paragraph or body content of the section.
  final String content;

  // 🔹 NEW: Optional custom color for links.
  final Color? linkColor;

  const SectionTextBlock({
    super.key,
    required this.title,
    required this.content,
    this.linkColor,
  });

  // Helper method to open the user's email app when tapping an email link.
  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch email app for: $email');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detect if the content contains a mailto link pattern.
    final bool hasMailLink = content.contains('mailto:');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            title,
            style: AppTextStyles.heading6.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textStrong(context),
            ),
          ),

          const SizedBox(height: 4),

          // Section content
          hasMailLink
              ? _buildLinkedText(context, content)
              : Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.text(context),
                  ),
                  textAlign: TextAlign.justify,
                ),
        ],
      ),
    );
  }

  // Parses markdown-style links `[label](mailto:address@example.com)`
  // and creates a tappable RichText.
  Widget _buildLinkedText(BuildContext context, String text) {
    final emailPattern = RegExp(r'\[([^\]]+)\]\(mailto:([^)]+)\)');
    final matches = emailPattern.allMatches(text);

    if (matches.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: AppColors.text(context),
        ),
        textAlign: TextAlign.justify,
      );
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final match in matches) {
      // Add normal text before each match
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      // Extract link data
      final label = match.group(1)!;
      final link = match.group(2)!;

      // Add clickable email text
      spans.add(
        TextSpan(
          text: label,
          style: TextStyle(
            color: linkColor ?? AppColors.primary(context), // 🔹 customizable color
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _launchEmail(link),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text after last link
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: TextStyle(
          color: AppColors.text(context), // normal text color
          fontSize: 17,
        ),
        children: spans,
      ),
    );
  }
}
