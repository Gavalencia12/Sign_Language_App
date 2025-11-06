import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

// A service responsible for providing the app’s **Privacy Policy** content
// using Flutter’s localization system instead of loading JSON files.
//
// This implementation retrieves all text directly from the `.arb`
// localization files through the [AppLocalizations] class,
// ensuring consistency and eliminating the need for external JSON assets.
//
// The service automatically adapts to the current app locale (e.g., `en`, `es`)
// and returns a structured [Map] containing all policy sections.
class PrivacyPolicyService {
  // Loads the privacy policy content according to the user's current locale.
  //
  // The method retrieves all localized strings from [AppLocalizations],
  // assembling them into a structured [Map] that mirrors the original JSON schema.
  //
  // Returns a [Map<String, String>] with each section title and content.
  static Future<Map<String, String>> loadPrivacyPolicy(
    BuildContext context,
  ) async {
    final loc = AppLocalizations.of(context)!;

    return {
      'privacy_policy_title': loc.privacy_policy_title,
      'effective_date': loc.effective_date,
      'section_1_title': loc.section_1_title,
      'section_1_content': loc.section_1_content,
      'section_2_title': loc.section_2_title,
      'section_2_content': loc.section_2_content,
      'section_3_title': loc.section_3_title,
      'section_3_content': loc.section_3_content,
      'section_4_title': loc.section_4_title,
      'section_4_content': loc.section_4_content,
      'section_5_title': loc.section_5_title,
      'section_5_content': loc.section_5_content,
      'section_6_title': loc.section_6_title,
      'section_6_content': loc.section_6_content,
      'section_7_title': loc.section_7_title,
      'section_7_content': loc.section_7_content,
    };
  }
}
