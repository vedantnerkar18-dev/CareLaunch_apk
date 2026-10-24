import 'symptom_category.dart';

class Question {
  final int id;
  final String text;
  final SymptomCategory category;
  final List<String> options; // exactly 3 labels, mildest first

  const Question({
    required this.id,
    required this.text,
    required this.category,
    required this.options,
  });

  /// The first option is worth 1 point, the second 2, the third 3.
  int pointsFor(int optionIndex) => optionIndex + 1;
}