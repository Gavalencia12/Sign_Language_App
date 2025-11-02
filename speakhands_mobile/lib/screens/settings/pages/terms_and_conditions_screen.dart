import 'package:flutter/material.dart';
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
