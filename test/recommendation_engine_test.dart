import 'package:flutter_test/flutter_test.dart';
import 'package:carelaunch/data/question_bank.dart';
import 'package:carelaunch/data/recommendation_data.dart';
import 'package:carelaunch/logic/assessment_scorer.dart';
import 'package:carelaunch/logic/recommendation_engine.dart';
import 'package:carelaunch/models/age_group.dart';
import 'package:carelaunch/models/screening_context.dart';
import 'package:carelaunch/models/symptom_category.dart';
import 'package:carelaunch/utils/launcher.dart';

void main() {
  const scorer = AssessmentScorer(questions: questionBank);
  const engine = RecommendationEngine();

  ScreeningContext context({bool safety = false}) => ScreeningContext(
        mobileConcern: false,
        duration: ConcernDuration.sixMonthsPlus,
        settings: ConcernSettings.multipleSettings,
        impact: DailyImpact.little,
        safetyConcern: safety,
      );

  // Every question answered with the same option (0 mild, 1 middle, 2 severe).
  AssessmentResult resultFor(int option, {bool safety = false}) =>
      scorer.evaluate(
        {for (final q in questionBank) q.id: option},
        context(safety: safety),
      );

  group('age groups', () {
    test('ages map to the right band', () {
      expect(AgeGroup.fromAge(5), AgeGroup.young);
      expect(AgeGroup.fromAge(8), AgeGroup.young);
      expect(AgeGroup.fromAge(9), AgeGroup.middle);
      expect(AgeGroup.fromAge(11), AgeGroup.middle);
      expect(AgeGroup.fromAge(12), AgeGroup.older);
      expect(AgeGroup.fromAge(14), AgeGroup.older);
      expect(AgeGroup.fromAge(null), AgeGroup.young);
    });

    test('every category has tips, videos and shopping ideas for every band', () {
      for (final c in SymptomCategory.values) {
        for (final g in AgeGroup.values) {
          expect(homeTips[c]![g], isNotEmpty, reason: '$c $g');
        }
        expect(videoIdeas[c], isNotEmpty, reason: '$c');
        expect(shoppingIdeas[c], isNotEmpty, reason: '$c');
      }
    });
  });

  group('Level 1 (all mild)', () {
    final recs = engine.build(resultFor(0), 7);

    test('still gives home tips, for at most 3 areas', () {
      expect(recs.tips, isNotEmpty);
      expect(recs.tips.length, lessThanOrEqualTo(3));
    });

    test('shows nothing beyond home tips', () {
      expect(recs.showGuided, isFalse);
      expect(recs.showSpecialists, isFalse);
      expect(recs.showHelplines, isFalse);
    });
  });

  group('Level 2 (all middle)', () {
    final recs = engine.build(resultFor(1), 10);

    test('adds videos and shopping, but no specialists', () {
      expect(recs.showGuided, isTrue);
      expect(recs.videos, isNotEmpty);
      expect(recs.shopping, isNotEmpty);
      expect(recs.showSpecialists, isFalse);
      expect(recs.showHelplines, isFalse);
    });

    test('searches carry the age phrase', () {
      expect(recs.videos.first.query, endsWith('kids aged 9 to 11'));
    });

    test('never advises on more than 3 areas', () {
      expect(recs.tips.length, lessThanOrEqualTo(3));
    });
  });

  group('Level 3 (all severe)', () {
    final recs = engine.build(resultFor(2), 13);

    test('adds specialists and helplines', () {
      expect(recs.showSpecialists, isTrue);
      expect(recs.showHelplines, isTrue);
      expect(recs.specialists.map((s) => s.query), contains('child psychologist'));
    });

    test('attention problems add a developmental paediatrician', () {
      expect(recs.specialists.map((s) => s.query),
          contains('developmental paediatrician'));
    });
  });

  test('a safety concern always shows helplines', () {
    final recs = engine.build(resultFor(0, safety: true), 9);
    expect(recs.showHelplines, isTrue);
    expect(recs.showSpecialists, isTrue);
  });

  test('helplines include Tele-MANAS 14416', () {
    expect(helplines.map((h) => h.number), contains('14416'));
  });

  group('Launcher', () {
    test('pincode must be 6 digits and not start with 0', () {
      expect(Launcher.isValidPincode('411001'), isTrue);
      expect(Launcher.isValidPincode(' 411001 '), isTrue);
      expect(Launcher.isValidPincode('41100'), isFalse);
      expect(Launcher.isValidPincode('4110011'), isFalse);
      expect(Launcher.isValidPincode('011001'), isFalse);
      expect(Launcher.isValidPincode('41100a'), isFalse);
    });

    test('links are built correctly', () {
      expect(Launcher.call('14416').toString(), 'tel:14416');
      expect(Launcher.youtubeSearch('yoga for kids').host, 'www.youtube.com');
      expect(Launcher.specialistsNear('child psychologist', '411001').toString(),
          contains('411001'));
    });
  });
}