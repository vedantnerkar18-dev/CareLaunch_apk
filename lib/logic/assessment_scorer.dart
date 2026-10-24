import '../models/question.dart';
import '../models/result_flag.dart';
import '../models/screening_context.dart';
import '../models/symptom_category.dart';
import 'fuzzy_engine.dart';
import 'screening_rules.dart';

class AssessmentResult {
  final FuzzyResult overall;
  final Map<SymptomCategory, FuzzyResult> byCategory;
  final Set<ResultFlag> flags;
  final ScreeningContext context;

  const AssessmentResult({
    required this.overall,
    required this.byCategory,
    required this.flags,
    required this.context,
  });
}

class AssessmentScorer {
  final List<Question> questions;
  final FuzzyEngine engine;
  final List<ScreeningRule> rules;

  const AssessmentScorer({
    required this.questions,
    this.engine = const FuzzyEngine(),
    this.rules = defaultRules,
  });

  /// [answers] maps question id -> chosen option index (0, 1 or 2).
  AssessmentResult evaluate(Map<int, int> answers, ScreeningContext context) {
    // Guard first, so bad input fails clearly instead of giving a wrong result.
    for (final q in questions) {
      final a = answers[q.id];
      if (a == null || a < 0 || a >= q.options.length) {
        throw ArgumentError('Question ${q.id} is missing or invalid.');
      }
    }

    int rawFor(List<Question> list) =>
        list.fold<int>(0, (sum, q) => sum + q.pointsFor(answers[q.id]!));

    final overall = engine.classify(
      engine.normalize(rawFor(questions), questions.length),
    );

    final byCategory = <SymptomCategory, FuzzyResult>{};
    for (final cat in SymptomCategory.values) {
      final inCat = questions.where((q) => q.category == cat).toList();
      if (inCat.isEmpty) continue;
      byCategory[cat] = engine.classify(
        engine.normalize(rawFor(inCat), inCat.length),
      );
    }

    final state = ScoringState(
      answers: answers,
      context: context,
      engine: engine,
      byCategory: byCategory,
      overall: overall,
    );

    if (context.mobileConcern) state.flags.add(ResultFlag.screenTimeTip);

    for (final rule in rules) {
      rule.apply(state);
    }

    return AssessmentResult(
      overall: state.overall,
      byCategory: state.byCategory,
      flags: state.flags,
      context: context,
    );
  }
}