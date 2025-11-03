// A model class that represents a Frequently Asked Question (FAQ) item.
// Each [FaqItem] contains:
// - A [question] — the main question text.
// - A list of [answers] — one or more possible answers or explanations.
class FaqItem {
  // The FAQ question text.
  final String question;

  // A list of answers or responses related to the question.
  final List<String> answers;

  // Creates a new [FaqItem] instance.
  // Both [question] and [answers] are required.
  const FaqItem({required this.question, required this.answers});

  // Creates a [FaqItem] from a [Map] (for example, from JSON or a local data source).

  // Expects a map with:
  // - 'question' --> a [String]
  // - 'answers' --> a [List<String>]

  // If `'answers'` is missing or null, it defaults to an empty list.
  factory FaqItem.fromMap(Map<String, dynamic> map) {
    return FaqItem(
      question: map['question'] as String,
      answers: List<String>.from(map['answers'] ?? const []),
    );
  }
}
