import '../logic/assessment_scorer.dart';
import 'result_flag.dart';
import 'severity_level.dart';
import 'symptom_category.dart';

/// One saved check-in for one child. It stores the outcome only, never the
/// individual answers.
class ScreeningRecord {
  final String id;
  final DateTime createdAt;
  final int ageAtScreening;
  final SeverityLevel overall;
  final double overallScore;
  final Map<SymptomCategory, SeverityLevel> categoryLevels;
  final bool safetyAlert;

  const ScreeningRecord({
    required this.id,
    required this.createdAt,
    required this.ageAtScreening,
    required this.overall,
    required this.overallScore,
    required this.categoryLevels,
    required this.safetyAlert,
  });

  /// For a result that has just been calculated (not saved yet).
  factory ScreeningRecord.fromResult(AssessmentResult r, {required int age}) =>
      ScreeningRecord(
        id: '',
        createdAt: DateTime.now(),
        ageAtScreening: age,
        overall: r.overall.level,
        overallScore: r.overall.score,
        categoryLevels: {
          for (final e in r.byCategory.entries) e.key: e.value.level,
        },
        safetyAlert: r.flags.contains(ResultFlag.safetyAlert),
      );

  Map<String, dynamic> toMap() => {
        'ageAtScreening': ageAtScreening,
        'overallLevel': overall.index,
        'overallScore': overallScore,
        'categoryLevels': {
          for (final e in categoryLevels.entries) e.key.name: e.value.index,
        },
        'safetyAlert': safetyAlert,
      };

  factory ScreeningRecord.fromMap(
    String id,
    DateTime createdAt,
    Map<String, dynamic> m,
  ) {
    final byName = SymptomCategory.values.asNameMap();
    final raw = (m['categoryLevels'] as Map?) ?? const {};
    return ScreeningRecord(
      id: id,
      createdAt: createdAt,
      ageAtScreening: (m['ageAtScreening'] as num?)?.toInt() ?? 0,
      overall: _level(m['overallLevel']),
      overallScore: (m['overallScore'] as num?)?.toDouble() ?? 0,
      categoryLevels: {
        for (final e in raw.entries)
          if (byName[e.key] != null) byName[e.key]!: _level(e.value),
      },
      safetyAlert: (m['safetyAlert'] as bool?) ?? false,
    );
  }

  static SeverityLevel _level(Object? value) {
    final last = SeverityLevel.values.length - 1;
    var i = (value as num?)?.toInt() ?? 0;
    if (i < 0) i = 0;
    if (i > last) i = last;
    return SeverityLevel.values[i];
  }
}