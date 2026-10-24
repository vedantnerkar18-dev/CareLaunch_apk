import '../models/result_flag.dart';
import '../models/screening_context.dart';
import '../models/severity_level.dart';
import '../models/symptom_category.dart';
import 'fuzzy_engine.dart';

// Question ids (they match question_bank.dart).
const int qSweatyPalms = 1;
const int qScared = 2;
const int qRestless = 3;
const int qBreathless = 4;
const int qTrembling = 5;
const int qIrritable = 10;
const int qLossOfInterest = 11;
const int qFatigue = 12;
const int qInsomnia = 13;

// Answer positions: 0 = mildest option, 2 = most severe option.
const int bottomAnswer = 0;
const int topAnswer = 2;

const List<SymptomCategory> _adhdCategories = [
  SymptomCategory.inattention,
  SymptomCategory.hyperactivity,
];

/// Everything a rule can read or change while one assessment is being scored.
class ScoringState {
  final Map<int, int> answers;
  final ScreeningContext context;
  final FuzzyEngine engine;
  final Map<SymptomCategory, FuzzyResult> byCategory;
  FuzzyResult overall;
  final Set<ResultFlag> flags = {};

  ScoringState({
    required this.answers,
    required this.context,
    required this.engine,
    required this.byCategory,
    required this.overall,
  });

  SeverityLevel? levelOf(SymptomCategory c) => byCategory[c]?.level;

  bool atLeast(SymptomCategory c, SeverityLevel level) {
    final r = byCategory[c];
    return r != null && r.level.index >= level.index;
  }

  void setLevel(SymptomCategory c, SeverityLevel level) {
    final r = byCategory[c];
    if (r != null) byCategory[c] = r.withLevel(level);
  }

  /// Only ever raises the overall level, never lowers it.
  void raiseOverallTo(SeverityLevel level) {
    if (overall.level.index < level.index) {
      overall = overall.withLevel(level);
    }
  }

  /// Scores just some of the questions, e.g. only the physical anxiety signs.
  FuzzyResult subScore(List<int> ids) {
    final raw = ids.fold<int>(0, (sum, id) => sum + answers[id]! + 1);
    return engine.classify(engine.normalize(raw, ids.length));
  }
}

/// A rule is one small, explainable piece of screening judgement
/// that sits on top of the fuzzy result.
abstract class ScreeningRule {
  const ScreeningRule();
  void apply(ScoringState s);
}

/// Sweating, breathlessness and trembling can come from physical causes
/// (for example asthma or thyroid problems), so physical signs without
/// worry or fear should send parents to a doctor first.
class PhysicalAnxietyRule extends ScreeningRule {
  const PhysicalAnxietyRule();

  @override
  void apply(ScoringState s) {
    if (s.answers[qBreathless] == topAnswer) {
      s.flags.add(ResultFlag.checkPhysicalHealth);
    }

    final physical = s.subScore([qSweatyPalms, qBreathless, qTrembling]);
    final worry = s.subScore([qScared, qRestless]);

    if (physical.level == SeverityLevel.level3 &&
        worry.level == SeverityLevel.level1) {
      s.flags.add(ResultFlag.checkPhysicalHealth);
      if (s.levelOf(SymptomCategory.anxiety) == SeverityLevel.level3) {
        s.setLevel(SymptomCategory.anxiety, SeverityLevel.level2);
      }
    }
  }
}

/// ADHD-type behaviours count for more when they last 6+ months and appear in
/// more than one setting. Otherwise they are capped at Level 2.
class AdhdPervasivenessRule extends ScreeningRule {
  const AdhdPervasivenessRule();

  @override
  void apply(ScoringState s) {
    final c = s.context;
    final established = c.duration == ConcernDuration.sixMonthsPlus &&
        c.settings == ConcernSettings.multipleSettings;
    if (established) return;

    for (final cat in _adhdCategories) {
      if (s.levelOf(cat) == SeverityLevel.level3) {
        s.setLevel(cat, SeverityLevel.level2);
        s.flags.add(ResultFlag.adhdNotYetPervasive);
      }
    }
  }
}

/// Low mood is judged over weeks, not days. Very recent mood changes
/// are capped at Level 2 unless they already disrupt daily life.
class MoodDurationRule extends ScreeningRule {
  const MoodDurationRule();

  @override
  void apply(ScoringState s) {
    final c = s.context;
    final recent = c.duration == ConcernDuration.underTwoWeeks;
    final bothTop = s.answers[qIrritable] == topAnswer &&
        s.answers[qLossOfInterest] == topAnswer;

    if (bothTop && !recent) {
      s.flags.add(ResultFlag.lowMoodWarning);
    }

    if (recent &&
        c.impact != DailyImpact.major &&
        s.levelOf(SymptomCategory.emotional) == SeverityLevel.level3) {
      s.setLevel(SymptomCategory.emotional, SeverityLevel.level2);
      s.flags.add(ResultFlag.lowMoodWatch);
    }
  }
}

/// Sleep trouble on its own should not jump to Level 3. Phone use decides
/// between Level 2 and Level 1. If daily life is badly affected, the rule
/// stays out of the way.
class SleepOnlyRule extends ScreeningRule {
  const SleepOnlyRule();

  @override
  void apply(ScoringState s) {
    final sleep = s.byCategory[SymptomCategory.sleep];
    if (sleep == null || sleep.level != SeverityLevel.level3) return;
    if (s.context.impact == DailyImpact.major) return;

    final othersAllLow = s.byCategory.entries
        .where((e) => e.key != SymptomCategory.sleep)
        .every((e) => e.value.level == SeverityLevel.level1);
    if (!othersAllLow) return;

    if (s.context.mobileConcern) {
      s.setLevel(SymptomCategory.sleep, SeverityLevel.level2);
      s.raiseOverallTo(SeverityLevel.level2);
      s.flags.add(ResultFlag.sleepScreenLink);
    } else {
      s.setLevel(SymptomCategory.sleep, SeverityLevel.level1);
      s.flags.add(ResultFlag.sleepHomeRoutine);
    }
  }
}

/// Anxiety and attention problems overlap, so when both are raised the
/// result says so and the overall level is at least Level 2.
class OverlapRule extends ScreeningRule {
  const OverlapRule();

  @override
  void apply(ScoringState s) {
    final adhdRaised =
        _adhdCategories.any((c) => s.atLeast(c, SeverityLevel.level2));
    if (s.atLeast(SymptomCategory.anxiety, SeverityLevel.level2) &&
        adhdRaised) {
      s.flags.add(ResultFlag.anxietyAdhdOverlap);
      s.raiseOverallTo(SeverityLevel.level2);
    }
  }
}

/// Insomnia together with anxiety is often worry-related.
class SleepWorryRule extends ScreeningRule {
  const SleepWorryRule();

  @override
  void apply(ScoringState s) {
    final insomniaPresent = s.answers[qInsomnia]! >= 1;
    if (insomniaPresent &&
        s.atLeast(SymptomCategory.sleep, SeverityLevel.level2) &&
        s.atLeast(SymptomCategory.anxiety, SeverityLevel.level2)) {
      s.flags.add(ResultFlag.sleepWorryLinked);
    }
  }
}

/// Tiredness without sleep trouble and without any other raised category
/// has many possible physical causes, so suggest a check-up.
class FatigueRule extends ScreeningRule {
  const FatigueRule();

  @override
  void apply(ScoringState s) {
    final tiredButSleeping = s.answers[qFatigue] == topAnswer &&
        s.answers[qInsomnia] == bottomAnswer;
    final othersAllLow = s.byCategory.entries
        .where((e) => e.key != SymptomCategory.sleep)
        .every((e) => e.value.level == SeverityLevel.level1);

    if (tiredButSleeping && othersAllLow) {
      s.flags.add(ResultFlag.checkPhysicalHealth);
    }
  }
}

/// Must run last: if the parent reports talk of death or self-harm,
/// nothing else matters. Overall level becomes 3 and the alert is shown.
class SafetyOverrideRule extends ScreeningRule {
  const SafetyOverrideRule();

  @override
  void apply(ScoringState s) {
    if (s.context.safetyConcern) {
      s.raiseOverallTo(SeverityLevel.level3);
      s.flags.add(ResultFlag.safetyAlert);
    }
  }
}

/// Order matters: SafetyOverrideRule is last so nothing can undo it.
const List<ScreeningRule> defaultRules = [
  PhysicalAnxietyRule(),
  AdhdPervasivenessRule(),
  MoodDurationRule(),
  SleepOnlyRule(),
  OverlapRule(),
  SleepWorryRule(),
  FatigueRule(),
  SafetyOverrideRule(),
];