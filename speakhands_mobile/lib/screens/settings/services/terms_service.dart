import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class TermsService {
  static Future<Map<String, dynamic>> loadTerms(BuildContext context) async {
    final locale = Localizations.localeOf(context).languageCode.split('_').first;
    final path = 'assets/terms_and_conditions_$locale.json';

    try {
      final data = await rootBundle.loadString(path);
      return jsonDecode(data);
    } catch (e) {
      final fallback = await rootBundle.loadString('assets/terms_and_conditions.json');
      return jsonDecode(fallback);
    }
  }
}
