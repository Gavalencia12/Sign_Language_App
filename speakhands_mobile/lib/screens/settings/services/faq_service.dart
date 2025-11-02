import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:speakhands_mobile/screens/settings/models/faq_item.dart';

class FaqService {
  static const String _assetPath = 'assets/faqs.json';

  Future<List<FaqItem>> loadFaqs() async {
    final raw = await rootBundle.loadString(_assetPath);
    final data = json.decode(raw) as Map<String, dynamic>;
    final list = (data['faqs'] as List? ?? []);
    return list.map((e) => FaqItem.fromMap(e as Map<String, dynamic>)).toList();
  }

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
