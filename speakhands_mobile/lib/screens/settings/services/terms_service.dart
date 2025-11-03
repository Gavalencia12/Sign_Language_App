import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

// A service class that loads the app’s **Terms and Conditions**
// from local JSON files with multilingual support.

// The service dynamically detects the user’s current locale
// (e.g., `en`, `es`, `fr`) and attempts to load a corresponding
// JSON file from the assets directory.

// If the localized file does not exist, it falls back to the
// default `terms_and_conditions.json`.
class TermsService {
  // Loads the terms and conditions file that matches the current app locale.
  // The method first extracts the base language code (e.g., "en" from "en_US")
  // to determine which localized file to load.
  // If the file for that language is not found, it loads the fallback JSON.

  // Returns a decoded [Map] containing the structured content of the terms.
  static Future<Map<String, dynamic>> loadTerms(BuildContext context) async {
    // Get the current locale (e.g., "en", "es")
    final locale =
        Localizations.localeOf(context).languageCode.split('_').first;
    final path = 'assets/terms_and_conditions_$locale.json';

    try {
      // Attempt to load the localized version
      final data = await rootBundle.loadString(path);
      return jsonDecode(data);
    } catch (e) {
      // Fallback to the default terms file if the localized one is not found
      final fallback = await rootBundle.loadString(
        'assets/terms_and_conditions.json',
      );
      return jsonDecode(fallback);
    }
  }
}
