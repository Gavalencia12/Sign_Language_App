class FaqItem {
  final String question;
  final List<String> answers;

  const FaqItem({
    required this.question,
    required this.answers,
  });

  factory FaqItem.fromMap(Map<String, dynamic> map) {
    return FaqItem(
      question: map['question'] as String,
      answers: List<String>.from(map['answers'] ?? const []),
    );
  }
}
