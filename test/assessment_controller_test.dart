import 'package:flutter_test/flutter_test.dart';
import 'package:carelaunch/data/question_bank.dart';
import 'package:carelaunch/models/result_flag.dart';
import 'package:carelaunch/models/severity_level.dart';
import 'package:carelaunch/state/assessment_controller.dart';

void main() {
  // Answers every step with [option], except the steps in [overrides]
  // (step index -> option). Then finishes.
  AssessmentController run(int option, {Map<int, int> overrides = const {}}) {
    final c = AssessmentController();
    c.begin();
    for (var i = 0; i < c.totalSteps; i++) {
      c.select(overrides[i] ?? option);
      if (!c.isLast) c.next();
    }
    c.finish();
    return c;
  }

  final first = questionBank.length; // index of the first context step

  test('there are 13 questions + 5 context steps', () {
    expect(AssessmentController().totalSteps, 18);
  });

  test('cannot move forward without picking an answer', () {
    final c = AssessmentController();
    c.next();
    expect(c.currentIndex, 0);
    c.select(1);
    c.next();
    expect(c.currentIndex, 1);
  });

  test('back goes one step and never below zero', () {
    final c = AssessmentController();
    c.back();
    expect(c.currentIndex, 0);
    c.select(0);
    c.next();
    c.back();
    expect(c.currentIndex, 0);
  });

  test('progress rises as answers are picked', () {
    final c = AssessmentController();
    expect(c.progress, 0.0);
    c.select(0);
    expect(c.progress > 0, true);
  });

  test('all mildest answers, safety No, mobile No: level 1, no flags', () {
    // context steps: mobile(1=No) duration(2) settings(1) impact(0) safety(0=No)
    final c = run(0, overrides: {
      first: 1,
      first + 1: 2,
      first + 2: 1,
    });
    expect(c.result!.overall.level, SeverityLevel.level1);
    expect(c.result!.flags.isEmpty, true);
  });

  test('mobile "Yes" adds the screen-time tip', () {
    final c = run(0, overrides: {first: 0, first + 1: 2, first + 2: 1});
    expect(c.result!.flags.contains(ResultFlag.screenTimeTip), true);
  });

  test('safety "Yes" forces level 3 and the alert', () {
    final c = run(0, overrides: {
      first: 1,
      first + 1: 2,
      first + 2: 1,
      first + 4: 1,
    });
    expect(c.result!.overall.level, SeverityLevel.level3);
    expect(c.result!.flags.contains(ResultFlag.safetyAlert), true);
  });

  test('severe answers over 6+ months in several places: level 3', () {
    // question answers all 2; context: mobile No, 6+ months, several places,
    // impact "A lot", safety No
    final c = run(2, overrides: {
      first: 1,
      first + 1: 2,
      first + 2: 1,
      first + 3: 2,
      first + 4: 0,
    });
    expect(c.result!.overall.level, SeverityLevel.level3);
    expect(c.result!.flags.contains(ResultFlag.safetyAlert), false);
  });

  test('reset clears the age and the result', () {
    final c = run(0, overrides: {first: 1, first + 1: 2, first + 2: 1});
    c.setAge(9);
    c.reset();
    expect(c.age == null, true);
    expect(c.result == null, true);
    expect(c.currentIndex, 0);
  });
}