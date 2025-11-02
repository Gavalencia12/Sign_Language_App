import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'dart:convert';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late Map<String, dynamic> _privacyData;

  @override
  void initState() {
    super.initState();
    _loadPrivacyPolicy();
  }

  Future<void> _loadPrivacyPolicy() async {
    String data = await rootBundle.rootBundle.loadString('assets/privacy_policy.json');
    setState(() {
      _privacyData = jsonDecode(data);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_privacyData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.privacy_policy)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.privacy_policy)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(_privacyData['content'].length, (index) {
            var section = _privacyData['content'][index];
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
