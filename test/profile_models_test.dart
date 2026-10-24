import 'package:flutter_test/flutter_test.dart';
import 'package:carelaunch/data/question_bank.dart';
import 'package:carelaunch/logic/assessment_scorer.dart';
import 'package:carelaunch/models/child_profile.dart';
import 'package:carelaunch/models/screening_context.dart';
import 'package:carelaunch/models/screening_record.dart';
import 'package:carelaunch/models/severity_level.dart';
import 'package:carelaunch/state/assessment_controller.dart';
import 'package:carelaunch/utils/validators.dart';

void main() {
  ChildProfile child(DateTime dob) =>
      ChildProfile(id: 'c1', name: 'Aarav', dob: dob);

  group('ChildProfile age', () {
    final c = child(DateTime(2018, 6, 15));

    test('is one less before the birthday and correct on it', () {
      expect(c.ageOn(DateTime(2026, 6, 14)), 7);
      expect(c.ageOn(DateTime(2026, 6, 15)), 8);
      expect(c.ageOn(DateTime(2026, 12, 31)), 8);
    });

    test('check-ins are allowed for ages 5 to 14 only', () {
      expect(c.canScreenOn(DateTime(2023, 6, 14)), isFalse); // age 4
      expect(c.canScreenOn(DateTime(2023, 6, 15)), isTrue); // age 5
      expect(c.canScreenOn(DateTime(2032, 6, 14)), isTrue); // age 13
      expect(c.canScreenOn(DateTime(2033, 6, 14)), isTrue); // age 14
      expect(c.canScreenOn(DateTime(2033, 6, 15)), isFalse); // age 15
    });

    test('survives a save and load', () {
      final back = ChildProfile.fromMap(
        'c1',
        ChildProfile(
          id: 'c1',
          name: ' Aarav ',
          dob: DateTime(2018, 6, 5),
          gender: 'Boy',
          language: ' Marathi ',
        ).toMap(),
      );
      expect(back.name, 'Aarav');
      expect(back.dob, DateTime(2018, 6, 5));
      expect(back.gender, 'Boy');
      expect(back.language, 'Marathi');
    });

    test('a blank language is stored as null', () {
      expect(
        ChildProfile(id: '', name: 'A', dob: DateTime(2018, 1, 1), language: '  ')
            .toMap()['language'],
        isNull,
      );
    });
  });

  group('ScreeningRecord', () {
    const scorer = AssessmentScorer(questions: questionBank);
    final result = scorer.evaluate(
      {for (final q in questionBank) q.id: 2},
      const ScreeningContext(
        mobileConcern: false,
        duration: ConcernDuration.sixMonthsPlus,
        settings: ConcernSettings.multipleSettings,
        impact: DailyImpact.little,
        safetyConcern: true,
      ),
    );

    test('keeps the outcome through a save and load', () {
      final saved = ScreeningRecord.fromResult(result, age: 9);
      final back = ScreeningRecord.fromMap('r1', DateTime(2026, 10, 24), saved.toMap());
      expect(back.ageAtScreening, 9);
      expect(back.overall, SeverityLevel.level3);
      expect(back.safetyAlert, isTrue);
      expect(back.categoryLevels.length, result.byCategory.length);
    });

    test('never stores individual answers', () {
      final keys = ScreeningRecord.fromResult(result, age: 9).toMap().keys;
      expect(keys, isNot(contains('answers')));
    });

    test('unknown or out-of-range values do not crash loading', () {
      final back = ScreeningRecord.fromMap('r2', DateTime(2026, 1, 1), {
        'overallLevel': 99,
        'categoryLevels': {'somethingNew': 1},
      });
      expect(back.overall, SeverityLevel.level3);
      expect(back.categoryLevels, isEmpty);
    });
  });

  test('the controller remembers the child and clears it on reset', () {
    final controller = AssessmentController();
    controller.startFor(child(DateTime(2018, 6, 15)), 8);
    expect(controller.child?.name, 'Aarav');
    expect(controller.age, 8);
    controller.reset();
    expect(controller.child, isNull);
    expect(controller.age, isNull);
  });

  group('Validators', () {
    test('email', () {
      expect(Validators.email('mum@example.com'), isNull);
      expect(Validators.email('mum@example'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('password needs 8 characters', () {
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password('12345678'), isNull);
    });

    test('phone is optional but must be a valid mobile number', () {
      expect(Validators.phoneOptional(''), isNull);
      expect(Validators.phoneOptional('98765 43210'), isNull);
      expect(Validators.phoneOptional('+91 9876543210'), isNull);
      expect(Validators.phoneOptional('12345'), isNotNull);
      expect(Validators.phoneOptional('5876543210'), isNotNull);
    });
  });
}