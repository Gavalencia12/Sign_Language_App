import 'package:flutter/material.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/screens/settings/services/privacy_policy_service.dart';
import '../../../widgets/section_text_block.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

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
      body: FutureBuilder<Map<String, dynamic>>(
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
          final sections = List<Map<String, dynamic>>.from(data['content']);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  sections.map((section) {
                    return SectionTextBlock(
                      title: section['section_title'],
                      content: section['section_content'],
                    );
                  }).toList(),
            ),
          );
        },
      ),
    );
  }
}
