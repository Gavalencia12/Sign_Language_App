import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:speakhands_mobile/screens/settings/models/faq_item.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

// Service responsible for loading FAQ items using localization (.arb) files
// instead of JSON assets.
//
// This ensures each question and answer is translated automatically
// when the user changes language.
class FaqService {
  // Loads FAQs directly from AppLocalizations.
  Future<List<FaqItem>> loadFaqs(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;

    final faqs = <FaqItem>[
      FaqItem(
        question: loc.faq_q01,
        answers: [
          loc.faq_q01_a1,
          loc.faq_q01_a2,
          loc.faq_q01_a3,
        ],
      ),
      FaqItem(
        question: loc.faq_q02,
        answers: [
          loc.faq_q02_a1,
          loc.faq_q02_a2,
          loc.faq_q02_a3,
        ],
      ),
      FaqItem(
        question: loc.faq_q03,
        answers: [
          loc.faq_q03_a1,
          loc.faq_q03_a2,
          loc.faq_q03_a3,
        ],
      ),
      FaqItem(
        question: loc.faq_q04,
        answers: [
          loc.faq_q04_a1,
          loc.faq_q04_a2,
          loc.faq_q04_a3,
        ],
      ),
      FaqItem(
        question: loc.faq_q05,
        answers: [
          loc.faq_q05_a1,
          loc.faq_q05_a2,
          loc.faq_q05_a3,
          loc.faq_q05_a4,
        ],
      ),
      FaqItem(
        question: loc.faq_q06,
        answers: [
          loc.faq_q06_a1,
          loc.faq_q06_a2,
          loc.faq_q06_a3,
          loc.faq_q06_a4,
        ],
      ),
      FaqItem(
        question: loc.faq_q07,
        answers: [
          loc.faq_q07_a1,
          loc.faq_q07_a2,
          loc.faq_q07_a3,
          loc.faq_q07_a4,
        ],
      ),
      FaqItem(
        question: loc.faq_q08,
        answers: [
          loc.faq_q08_a1,
          loc.faq_q08_a2,
          loc.faq_q08_a3,
          loc.faq_q08_a4,
        ],
      ),
      FaqItem(
        question: loc.faq_q09,
        answers: [
          loc.faq_q09_a1,
          loc.faq_q09_a2,
          loc.faq_q09_a3,
          loc.faq_q09_a4,
        ],
      ),
      FaqItem(
        question: loc.faq_q10,
        answers: [
          loc.faq_q10_a1,
          loc.faq_q10_a2,
          loc.faq_q10_a3,
          loc.faq_q10_a4,
        ],
      ),
    ];

    return faqs;
  }

  // Filters the list of FAQs by query (case-insensitive).
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
