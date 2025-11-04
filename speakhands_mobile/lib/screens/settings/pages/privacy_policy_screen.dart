import 'package:flutter/material.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/screens/settings/services/privacy_policy_service.dart';
import '../../../widgets/section_text_block.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

// A screen that displays the **Privacy Policy** of the SpeakHands application.

// This screen retrieves structured policy data asynchronously
// from [PrivacyPolicyService], and then renders each section
// using the [SectionTextBlock] widget.

// Features:
// - Dynamically loads policy content (title and text sections).
// - Uses localized strings through [AppLocalizations].
// - Adapts colors according to the current app theme (light/dark).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _launchEmail(BuildContext context, String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró una aplicación de correo configurada.'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // Localization instance for multi-language text support.
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface(context),

      // Top navigation bar with themed title and back button.
      appBar: AppBar(
        title: Text(
          loc.privacy_policy,
          style: TextStyle(color: AppColors.onSurface(context)),
        ),
        backgroundColor: AppColors.surface(context),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.onSurface(context)),
      ),

      // Main body — uses [FutureBuilder] to handle asynchronous data loading.
      body: FutureBuilder<Map<String, String>>(
        future: PrivacyPolicyService.loadPrivacyPolicy(context),
        builder: (context, snapshot) {
          // Loading state: display progress indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state: handle missing or invalid data
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text(
                loc.error_loading_data,
                style: TextStyle(color: AppColors.text(context)),
              ),
            );
          }

          // Success: parse and display all content sections
          final data = snapshot.data!;

          final sections = [
            {
              'section_title': data['section_1_title'],
              'section_content': data['section_1_content']
            },
            {
              'section_title': data['section_2_title'],
              'section_content': data['section_2_content']
            },
            {
              'section_title': data['section_3_title'],
              'section_content': data['section_3_content']
            },
            {
              'section_title': data['section_4_title'],
              'section_content': data['section_4_content']
            },
            {
              'section_title': data['section_5_title'],
              'section_content': data['section_5_content']
            },
            {
              'section_title': data['section_6_title'],
              'section_content': data['section_6_content']
            },
            {
              'section_title': data['section_7_title'],
              'section_content': data['section_7_content']
            },
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data['privacy_policy_title']} - ${data['effective_date']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...sections.map((section) {
                  return SectionTextBlock(
                    title: section['section_title'] ?? '',
                    content: section['section_content'] ?? '',
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinkedText(BuildContext context, String text) {
    final emailPattern = RegExp(r'\[([^\]]+)\]\(mailto:([^)]+)\)');
    final matches = emailPattern.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: const TextStyle(fontSize: 15), textAlign: TextAlign.justify);
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      final label = match.group(1)!;
      final link = match.group(2)!;

      spans.add(
        TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _launchEmail(context, link),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(style: const TextStyle(color: Colors.black, fontSize: 15), children: spans),
    );
  }
}
