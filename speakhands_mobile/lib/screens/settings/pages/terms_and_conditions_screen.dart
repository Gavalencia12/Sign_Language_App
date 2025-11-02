/* import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'dart:convert';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  @override
  _TermsAndConditionsScreenState createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  late Map<String, dynamic> _termsData;

  @override
  void initState() {
    super.initState();
    _loadTermsAndConditions();
  }

  Future<void> _loadTermsAndConditions() async {
    String data = await rootBundle.rootBundle.loadString('assets/terms_and_conditions.json');
    setState(() {
      _termsData = jsonDecode(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_termsData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.terms_and_conditions)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.terms_and_conditions)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(_termsData['content'].length, (index) {
            var section = _termsData['content'][index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section['section_title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(section['section_content'], style: TextStyle(fontSize: 15), textAlign: TextAlign.justify),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/screens/settings/services/terms_service.dart';
import 'package:speakhands_mobile/screens/settings/widgets/terms_section.dart';

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
              return TermsSection(
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
