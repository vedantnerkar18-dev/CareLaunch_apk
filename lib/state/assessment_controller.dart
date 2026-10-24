import 'package:flutter/foundation.dart';

import '../data/checkin_copy.dart';
import '../data/context_steps.dart';
import '../data/question_bank.dart';
import '../logic/assessment_scorer.dart';
import '../models/child_profile.dart';
import '../models/screening_context.dart';
import '../models/step_def.dart';
import '../models/symptom_category.dart';

/// Holds the state of one assessment. It contains no widgets:
/// the screens only read from it and call its methods.
class AssessmentController extends ChangeNotifier {
  AssessmentController({
    this.scorer = const AssessmentScorer(questions: questionBank),
  }) : steps = [
          for (final q in questionBank)
            StepDef(prompt: q.text, options: q.options),
          ...contextSteps,
        ] {
    _picked = List<int?>.filled(steps.length, null);
  }

  final AssessmentScorer scorer;
  final List<StepDef> steps;

  late List<int?> _picked; // chosen option index for each step, or null
  int _index = 0;
  int? age;
  ChildProfile? child; // who this check-in is for (null in unit tests)
  AssessmentResult? result;

  /// What the caregiver said was on their mind (optional, never scored).
  final Set<SymptomCategory> concerns = {};

  int get currentIndex => _index;
  int get totalSteps => steps.length;
  StepDef get currentStep => steps[_index];
  int? get pickedForCurrent => _picked[_index];
  bool get isLast => _index == steps.length - 1;

  /// The rocket climbs as questions get answered (0.0 to 1.0).
  double get progress {
    final answered = _picked.where((p) => p != null).length;
    return answered / steps.length;
  }

  void toggleConcern(SymptomCategory c) {
    if (!concerns.remove(c)) concerns.add(c);
    notifyListeners();
  }

  /// The heading above the current question, e.g. "Sleep and tiredness".
  String get sectionLabel => _index < questionBank.length
      ? sectionTitles[questionBank[_index].category]!
      : contextSectionTitle;

  /// A short, kind message at a few points along the way (otherwise null).
  String? get encouragement {
    if (_index == 0) return 'There are no right or wrong answers. Go with your first instinct.';
    if (_index == steps.length ~/ 3) return 'Nice, you are a third of the way there.';
    if (_index == steps.length ~/ 2) return 'Halfway there. You are doing really well.';
    if (_index == questionBank.length) {
      return 'Almost done. These last few questions help us see the bigger picture.';
    }
    if (isLast) return 'Last one. Thank you for taking the time.';
    return null;
  }

  void setAge(int value) {
    age = value;
    notifyListeners();
  }

  /// Begins a check-in for a saved child, using their current age.
  void startFor(ChildProfile selected, int currentAge) {
    child = selected;
    age = currentAge;
    concerns.clear();
    begin();
  }

  /// Starts a fresh run of the questions (keeps the chosen age).
  void begin() {
    _picked = List<int?>.filled(steps.length, null);
    _index = 0;
    result = null;
    notifyListeners();
  }

  void select(int optionIndex) {
    _picked[_index] = optionIndex;
    notifyListeners();
  }

  void next() {
    if (_picked[_index] == null || isLast) return;
    _index++;
    notifyListeners();
  }

  void back() {
    if (_index == 0) return;
    _index--;
    notifyListeners();
  }

  /// Turns the picked options into answers + context and scores them.
  void finish() {
    final answers = <int, int>{
      for (var i = 0; i < questionBank.length; i++)
        questionBank[i].id: _picked[i]!,
    };

    final b = questionBank.length; // the first context step comes right after
    final context = ScreeningContext(
      mobileConcern: _picked[b] == 0, // option 0 = "Yes"
      duration: ConcernDuration.values[_picked[b + 1]!],
      settings: ConcernSettings.values[_picked[b + 2]!],
      impact: DailyImpact.values[_picked[b + 3]!],
      safetyConcern: _picked[b + 4] == 1, // option 1 = "Yes"
    );

    result = scorer.evaluate(answers, context);
    notifyListeners();
  }

  void reset() {
    age = null;
    child = null;
    concerns.clear();
    begin();
  }
}