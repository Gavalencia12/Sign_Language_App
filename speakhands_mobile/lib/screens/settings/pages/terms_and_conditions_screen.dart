import 'package:flutter/material.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/screens/settings/services/terms_service.dart';
import '../../../widgets/section_text_block.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

/// The **TermsAndConditionsScreen** displays the application's terms of service
/// in a structured, readable format.

/// This screen loads the terms content asynchronously using [TermsService]
/// and presents each section using the [SectionTextBlock] widget.

/// Features:
/// - Displays terms divided into titled sections.
/// - Handles loading, success, and error states gracefully.
/// - Supports multiple languages through [AppLocalizations].
/// - Adapts its colors dynamically to the current theme mode.
class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load localized strings
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface(context),

      // App bar with localized title and themed icons.
      appBar: AppBar(
        title: Text(
          loc.terms_and_conditions,
          style: TextStyle(color: AppColors.onSurface(context)),
        ),
        backgroundColor: AppColors.surface(context),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.onSurface(context)),
      ),

      // Body content built dynamically with [FutureBuilder]
      // to handle asynchronous loading from the [TermsService].
      body: FutureBuilder<Map<String, String>>(
        future: TermsService.loadTerms(context),
        builder: (context, snapshot) {
          // Loading state — display progress indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text(
                loc.error_loading_data,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.text(context)),
              ),
            );
          }

          final terms = snapshot.data!;

          // Construir las secciones con las claves del mapa
          final sections = [
            {
              'section_title': terms['terms_section_1_title'],
              'section_content': terms['terms_section_1_content'],
            },
            {
              'section_title': terms['terms_section_2_title'],
              'section_content': terms['terms_section_2_content'],
            },
            {
              'section_title': terms['terms_section_3_title'],
              'section_content': terms['terms_section_3_content'],
            },
            {
              'section_title': terms['terms_section_4_title'],
              'section_content': terms['terms_section_4_content'],
            },
            {
              'section_title': terms['terms_section_5_title'],
              'section_content': terms['terms_section_5_content'],
            },
            {
              'section_title': terms['terms_section_6_title'],
              'section_content': terms['terms_section_6_content'],
            },
          ];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              return SectionTextBlock(
                title: section['section_title'] ?? '',
                content: section['section_content'] ?? '',
              );
            },
          );
        },
      ),
    );
  }
}
