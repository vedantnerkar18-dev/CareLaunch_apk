import 'package:flutter_test/flutter_test.dart';
import 'package:carelaunch/data/question_bank.dart';
import 'package:carelaunch/logic/assessment_scorer.dart';
import 'package:carelaunch/models/result_flag.dart';
import 'package:carelaunch/models/screening_context.dart';
import 'package:carelaunch/models/severity_level.dart';
import 'package:carelaunch/models/symptom_category.dart';

void main() {
  const scorer = AssessmentScorer(questions: questionBank);

  // A "settled" context: 6+ months, several settings, little daily impact.
  const base = ScreeningContext(
    mobileConcern: false,
    duration: ConcernDuration.sixMonthsPlus,
    settings: ConcernSettings.multipleSettings,
    impact: DailyImpact.little,
    safetyConcern: false,
  );

  Map<int, int> allAnswers(int index) => {
        for (final q in questionBank) q.id: index,
      };

  Map<int, int> withCategoryHigh(Map<int, int> answers, SymptomCategory c) {
    for (final q in questionBank) {
      if (q.category == c) answers[q.id] = 2;
    }
    return answers;
  }

  // ---------- basics ----------

  test('all lowest answers: everything is level 1, no flags', () {
    final r = scorer.evaluate(allAnswers(0), base);
    expect(r.overall.level, SeverityLevel.level1);
    for (final result in r.byCategory.values) {
      expect(result.level, SeverityLevel.level1);
    }
    expect(r.flags.isEmpty, true);
  });

  test('all highest answers: everything is level 3', () {
    final r = scorer.evaluate(allAnswers(2), base);
    expect(r.overall.level, SeverityLevel.level3);
    expect(r.byCategory[SymptomCategory.sleep]!.level, SeverityLevel.level3);
    expect(r.byCategory[SymptomCategory.inattention]!.level,
        SeverityLevel.level3);
  });

  test('only anxiety is high: category shows it, overall does not', () {
    final answers = withCategoryHigh(allAnswers(0), SymptomCategory.anxiety);
    final r = scorer.evaluate(answers, base);
    expect(r.byCategory[SymptomCategory.anxiety]!.level, SeverityLevel.level3);
    expect(r.byCategory[SymptomCategory.sleep]!.level, SeverityLevel.level1);
    expect(r.overall.level, SeverityLevel.level2);
  });

  test('missing answer throws an error', () {
    final answers = allAnswers(0)..remove(5);
    expect(() => scorer.evaluate(answers, base), throwsArgumentError);
  });

  test('mobile concern adds the screen-time tip', () {
    final r = scorer.evaluate(
        allAnswers(0), base.copyWith(mobileConcern: true));
    expect(r.flags, contains(ResultFlag.screenTimeTip));
  });

  // ---------- sleep ----------

  test('sleep only high + mobile concern: level 2, overall raised', () {
    final answers = withCategoryHigh(allAnswers(0), SymptomCategory.sleep);
    final r = scorer.evaluate(answers, base.copyWith(mobileConcern: true));
    expect(r.byCategory[SymptomCategory.sleep]!.level, SeverityLevel.level2);
    expect(r.overall.level, SeverityLevel.level2);
    expect(r.flags, contains(ResultFlag.sleepScreenLink));
  });

  test('sleep only high + no mobile concern: stays level 1', () {
    final answers = withCategoryHigh(allAnswers(0), SymptomCategory.sleep);
    final r = scorer.evaluate(answers, base);
    expect(r.byCategory[SymptomCategory.sleep]!.level, SeverityLevel.level1);
    expect(r.overall.level, SeverityLevel.level1);
    expect(r.flags, contains(ResultFlag.sleepHomeRoutine));
  });

  test('sleep only high but daily life badly affected: rule steps aside', () {
    final answers = withCategoryHigh(allAnswers(0), SymptomCategory.sleep);
    final r = scorer.evaluate(answers, base.copyWith(impact: DailyImpact.major));
    expect(r.byCategory[SymptomCategory.sleep]!.level, SeverityLevel.level3);
  });

  test('sleep high AND anxiety high: sleep rule does not apply, worry note', () {
    var answers = withCategoryHigh(allAnswers(0), SymptomCategory.sleep);
    answers = withCategoryHigh(answers, SymptomCategory.anxiety);
    final r = scorer.evaluate(answers, base);
    expect(r.byCategory[SymptomCategory.sleep]!.level, SeverityLevel.level3);
    expect(r.flags, isNot(contains(ResultFlag.sleepHomeRoutine)));
    expect(r.flags, contains(ResultFlag.sleepWorryLinked));
  });

  test('tired but sleeping fine, nothing else raised: check-up note', () {
    final answers = allAnswers(0);
    answers[12] = 2; // fatigue: Often
    final r = scorer.evaluate(answers, base);
    expect(r.flags, contains(ResultFlag.checkPhysicalHealth));
    expect(r.overall.level, SeverityLevel.level1);
  });

  // ---------- anxiety ----------

  test('physical signs without worry: capped at level 2 + doctor note', () {
    final answers = allAnswers(0);
    answers[1] = 2; // sweaty palms
    answers[4] = 2; // breathlessness: Daily
    answers[5] = 2; // trembling: Severe
    answers[3] = 1; // restlessness: Sometimes (worry stays low)
    final r = scorer.evaluate(answers, base);
    expect(r.byCategory[SymptomCategory.anxiety]!.level, SeverityLevel.level2);
    expect(r.flags, contains(ResultFlag.checkPhysicalHealth));
  });

  test('same physical signs WITH worry: stays level 3', () {
    final answers = allAnswers(0);
    answers[1] = 2;
    answers[4] = 2;
    answers[5] = 2;
    answers[2] = 2; // scared or nervous: Often
    answers[3] = 2; // restlessness: Often
    final r = scorer.evaluate(answers, base);
    expect(r.byCategory[SymptomCategory.anxiety]!.level, SeverityLevel.level3);
  });

  test('daily breathlessness alone raises the doctor note', () {
    final answers = allAnswers(0);
    answers[4] = 2;
    final r = scorer.evaluate(answers, base);
    expect(r.flags, contains(ResultFlag.checkPhysicalHealth));
  });

  // ---------- ADHD-type behaviours ----------

  test('attention problems for under 6 months: capped at level 2', () {
    final answers = withCategoryHigh(allAnswers(0), SymptomCategory.inattention);
    final r = scorer.evaluate(
        answers, base.copyWith(duration: ConcernDuration.twoWeeksToSixMonths));
    expect(r.byCategory[SymptomCategory.inattention]!.level,
        SeverityLevel.level2);
    expect(r.flags, contains(ResultFlag.adhdNotYetPervasive));
  });

  test('attention problems at home only: capped at level 2', () {
    final answers = withCategoryHigh(allAnswers(0), SymptomCategory.inattention);
    final r = scorer.evaluate(
        answers, base.copyWith(settings: ConcernSettings.oneSetting));
    expect(r.byCategory[SymptomCategory.inattention]!.level,
        SeverityLevel.level2);
  });

  test('attention problems 6+ months in several places: stays level 3', () {
    final answers = withCategoryHigh(allAnswers(0), SymptomCategory.inattention);
    final r = scorer.evaluate(answers, base);
    expect(r.byCategory[SymptomCategory.inattention]!.level,
        SeverityLevel.level3);
    expect(r.flags, isNot(contains(ResultFlag.adhdNotYetPervasive)));
  });

  test('anxiety and attention both raised: overlap note, overall >= 2', () {
    var answers = withCategoryHigh(allAnswers(0), SymptomCategory.anxiety);
    answers = withCategoryHigh(answers, SymptomCategory.inattention);
    final r = scorer.evaluate(answers, base);
    expect(r.flags, contains(ResultFlag.anxietyAdhdOverlap));
    expect(r.overall.level.index >= SeverityLevel.level2.index, true);
  });

  // ---------- mood ----------

  test('low mood signs lasting weeks: warning note', () {
    final answers = withCategoryHigh(allAnswers(0), SymptomCategory.emotional);
    final r = scorer.evaluate(
        answers, base.copyWith(duration: ConcernDuration.twoWeeksToSixMonths));
    expect(r.byCategory[SymptomCategory.emotional]!.level, SeverityLevel.level3);
    expect(r.flags, contains(ResultFlag.lowMoodWarning));
  });

  test('very recent mood change: capped at level 2, watch note', () {
    final answers = withCategoryHigh(allAnswers(0), SymptomCategory.emotional);
    final r = scorer.evaluate(
        answers, base.copyWith(duration: ConcernDuration.underTwoWeeks));
    expect(r.byCategory[SymptomCategory.emotional]!.level, SeverityLevel.level2);
    expect(r.flags, contains(ResultFlag.lowMoodWatch));
    expect(r.flags, isNot(contains(ResultFlag.lowMoodWarning)));
  });

  test('very recent mood change but daily life badly affected: not capped', () {
    final answers = withCategoryHigh(allAnswers(0), SymptomCategory.emotional);
    final r = scorer.evaluate(
        answers,
        base.copyWith(
            duration: ConcernDuration.underTwoWeeks,
            impact: DailyImpact.major));
    expect(r.byCategory[SymptomCategory.emotional]!.level, SeverityLevel.level3);
  });

  // ---------- safety ----------

  test('safety concern forces overall level 3 even if scores are low', () {
    final r = scorer.evaluate(
        allAnswers(0), base.copyWith(safetyConcern: true));
    expect(r.overall.level, SeverityLevel.level3);
    expect(r.flags, contains(ResultFlag.safetyAlert));
  });

  test('no safety concern: no alert', () {
    final r = scorer.evaluate(allAnswers(2), base);
    expect(r.flags, isNot(contains(ResultFlag.safetyAlert)));
  });
}