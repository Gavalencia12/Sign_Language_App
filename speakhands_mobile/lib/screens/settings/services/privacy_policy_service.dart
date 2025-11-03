import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

// A service responsible for loading the app’s **Privacy Policy** content
// from local JSON assets, with multilingual support.

// The service attempts to load a language-specific version of the policy file
// based on the current locale (e.g., `privacy_policy_es.json` for Spanish).
// If the localized file does not exist, it gracefully falls back to the
// default `privacy_policy.json`.
class PrivacyPolicyService {
  // Loads the privacy policy JSON data according to the user's locale.
  // Uses [Localizations.localeOf] to detect the current language code.
  // The method first attempts to load a language-specific file, and if that fails,
  // it loads the default English (or fallback) version.

  // Returns a decoded [Map] representing the policy structure.
  static Future<Map<String, dynamic>> loadPrivacyPolicy(
    BuildContext context,
  ) async {
    final locale = Localizations.localeOf(context).languageCode;
    final path = 'assets/privacy_policy_$locale.json';

    try {
      // Try loading the localized version
      final data = await rootBundle.loadString(path);
      return jsonDecode(data);
    } catch (e) {
      // Fallback to default policy if localization file doesn't exist
      final fallback = await rootBundle.loadString(
        'assets/privacy_policy.json',
      );
      return jsonDecode(fallback);
    }
  }
}
