import 'package:flutter_test/flutter_test.dart';
import 'package:carelaunch/data/question_bank.dart';
import 'package:carelaunch/models/child_profile.dart';
import 'package:carelaunch/models/symptom_category.dart';
import 'package:carelaunch/state/assessment_controller.dart';

void main() {
  final child = ChildProfile(id: 'c1', name: 'Aarav', dob: DateTime(2018, 6, 15));

  test('concerns can be toggled, and are cleared for the next check-in', () {
    final c = AssessmentController();
    c.startFor(child, 8);
    c.toggleConcern(SymptomCategory.sleep);
    c.toggleConcern(SymptomCategory.anxiety);
    expect(c.concerns, {SymptomCategory.sleep, SymptomCategory.anxiety});
    c.toggleConcern(SymptomCategory.sleep);
    expect(c.concerns, {SymptomCategory.anxiety});
    c.startFor(child, 8);
    expect(c.concerns, isEmpty);
  });

  test('every step has a section label', () {
    final c = AssessmentController();
    c.startFor(child, 8);
    for (var i = 0; i < c.totalSteps; i++) {
      expect(c.sectionLabel, isNotEmpty);
      if (i < c.totalSteps - 1) {
        c.select(0);
        c.next();
      }
    }
  });

  test('encouragement appears at set points and nowhere else is empty text', () {
    final c = AssessmentController();
    c.startFor(child, 8);
    final shown = <int>[];
    for (var i = 0; i < c.totalSteps; i++) {
      final m = c.encouragement;
      if (m != null) {
        expect(m, isNotEmpty);
        shown.add(i);
      }
      if (i < c.totalSteps - 1) {
        c.select(0);
        c.next();
      }
    }
    expect(shown, [0, c.totalSteps ~/ 3, c.totalSteps ~/ 2, questionBank.length, c.totalSteps - 1]);
  });
}