import 'package:flutter/material.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/screens/settings/services/terms_service.dart';
import '../../../widgets/section_text_block.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface(context),
      appBar: AppBar(
        title: Text(
          loc.terms_and_conditions,
          style: TextStyle(color: AppColors.onSurface(context)),
        ),
        backgroundColor: AppColors.surface(context),
        centerTitle: true,
        iconTheme: IconThemeData(
    color: AppColors.onSurface(context),
  ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: TermsService.loadTerms(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null || snapshot.data!['content'] == null) {
            return Center(
              child: Text(
                loc.error_loading_data,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.text(context)),
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
