import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class PrivacyPolicyService {
  static Future<Map<String, dynamic>> loadPrivacyPolicy(BuildContext context) async {
    final locale = Localizations.localeOf(context).languageCode;
    final path = 'assets/privacy_policy_$locale.json';

    try {
      final data = await rootBundle.loadString(path);
      return jsonDecode(data);
    } catch (e) {
      // Carga por defecto (en caso de que el idioma no exista)
      final fallback = await rootBundle.loadString('assets/privacy_policy.json');
      return jsonDecode(fallback);
    }
  }
}
