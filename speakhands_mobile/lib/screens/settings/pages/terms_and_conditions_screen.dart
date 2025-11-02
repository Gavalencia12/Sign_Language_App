import 'package:flutter/material.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/screens/settings/services/terms_service.dart';
import '../../../widgets/section_text_block.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.terms_and_conditions)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: TermsService.loadTerms(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null || snapshot.data!['content'] == null) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.error_loading_data,
                textAlign: TextAlign.center,
              ),
            );
          }

          final sections = List<Map<String, dynamic>>.from(snapshot.data!['content']);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              return SectionTextBlock(
                title: section['section_title'],
                content: section['section_content'],
              );
            },
          );
        },
      ),
    );
  }
}
