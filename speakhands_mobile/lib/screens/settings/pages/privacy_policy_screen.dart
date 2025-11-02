import 'package:flutter/material.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/screens/settings/services/privacy_policy_service.dart';
import '../../../widgets/section_text_block.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.privacy_policy)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: PrivacyPolicyService.loadPrivacyPolicy(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text(AppLocalizations.of(context)!.error_loading_data));
          }

          final data = snapshot.data!;
          final sections = List<Map<String, dynamic>>.from(data['content']);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sections.map((section) {
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