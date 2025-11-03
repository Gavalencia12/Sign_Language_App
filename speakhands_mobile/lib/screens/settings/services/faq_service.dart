import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:speakhands_mobile/screens/settings/models/faq_item.dart';

// A service class responsible for loading and filtering
// 'Frequently Asked Questions (FAQs)' from a local JSON file.

// The data file should be located at:
// 'assets/faqs.json'

// Each FAQ entry is represented as a [FaqItem] model containing a question
// and a list of possible answers.
class FaqService {
  /// Path to the JSON file that stores FAQ data.
  static const String _assetPath = 'assets/faqs.json';

  // Loads all FAQ items from the local JSON asset asynchronously.

  // Returns a list of [FaqItem] objects parsed from the JSON data.
  // If the file is empty or missing, it returns an empty list instead of throwing.
  Future<List<FaqItem>> loadFaqs() async {
    final raw = await rootBundle.loadString(_assetPath);
    final data = json.decode(raw) as Map<String, dynamic>;
    final list = (data['faqs'] as List? ?? []);
    return list.map((e) => FaqItem.fromMap(e as Map<String, dynamic>)).toList();
  }

  // Filters the provided list of FAQs by a given query string [q].
  // The search is *case-insensitive* and matches both questions and answers.

  // Returns all FAQs that contain the query in their question or answer text.
  // If [q] is empty or only whitespace, the original list is returned.
  List<FaqItem> filter(List<FaqItem> faqs, String q) {
    if (q.trim().isEmpty) return faqs;

    final needle = q.toLowerCase();

    return faqs.where((f) {
      final inQ = f.question.toLowerCase().contains(needle);
      final inA = f.answers.any((a) => a.toLowerCase().contains(needle));
      return inQ || inA;
    }).toList();
  }
}
