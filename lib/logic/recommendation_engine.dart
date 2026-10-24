import '../data/recommendation_data.dart';
import '../models/age_group.dart';
import '../models/result_flag.dart';
import '../models/severity_level.dart';
import '../models/symptom_category.dart';
import 'assessment_scorer.dart';

class CategoryTips {
  final SymptomCategory category;
  final List<String> tips;
  const CategoryTips(this.category, this.tips);
}

/// One tappable search (a video topic, a shopping topic, a specialist type).
class SearchItem {
  final String label;
  final String query;
  const SearchItem(this.label, this.query);
}

class Recommendations {
  final AgeGroup ageGroup;
  final List<CategoryTips> tips; // Level 1: always shown
  final List<SearchItem> videos; // Level 2
  final List<SearchItem> shopping; // Level 2
  final List<SearchItem> specialists; // Level 3 (empty below Level 3)
  final bool showHelplines;

  const Recommendations({
    required this.ageGroup,
    required this.tips,
    required this.videos,
    required this.shopping,
    required this.specialists,
    required this.showHelplines,
  });

  bool get showGuided => videos.isNotEmpty || shopping.isNotEmpty;
  bool get showSpecialists => specialists.isNotEmpty;
}

/// Pure Dart (no Flutter), so the choices can be unit tested.
class RecommendationEngine {
  const RecommendationEngine();

  static const int _maxFocus = 3;

  Recommendations build(AssessmentResult result, int? age) {
    final group = AgeGroup.fromAge(age);
    final focus = _focusCategories(result);
    final overall = result.overall.level;

    final tips = [
      for (final c in focus) CategoryTips(c, homeTips[c]![group]!),
    ];

    final guided = overall.index >= SeverityLevel.level2.index;
    final videos = <SearchItem>[
      if (guided)
        for (final c in focus)
          SearchItem(
            '${c.label}: ${videoIdeas[c]!.first.label}',
            '${videoIdeas[c]!.first.topic} ${group.searchPhrase}',
          ),
    ];
    final shopping = <SearchItem>[
      if (guided)
        for (final c in focus)
          SearchItem(
            '${c.label}: ${shoppingIdeas[c]!.first.label}',
            '${shoppingIdeas[c]!.first.topic} ${group.searchPhrase}',
          ),
    ];

    final needsSpecialist = overall == SeverityLevel.level3;
    final specialists = <SearchItem>[
      if (needsSpecialist) ...[
        const SearchItem('Child psychologist', 'child psychologist'),
        if (_adhdAtLevel3(result))
          const SearchItem(
              'Developmental paediatrician', 'developmental paediatrician'),
        if (result.flags.contains(ResultFlag.checkPhysicalHealth))
          const SearchItem('Paediatrician', 'paediatrician'),
      ],
    ];

    return Recommendations(
      ageGroup: group,
      tips: tips,
      videos: videos,
      shopping: shopping,
      specialists: specialists,
      showHelplines:
          needsSpecialist || result.flags.contains(ResultFlag.safetyAlert),
    );
  }

  /// The areas to give advice on: every area at Level 2 or above (highest
  /// score first, at most 3). If none is that high, the 2 highest-scoring areas.
  List<SymptomCategory> _focusCategories(AssessmentResult result) {
    final sorted = result.byCategory.entries.toList()
      ..sort((a, b) => b.value.score.compareTo(a.value.score));
    final raised = sorted
        .where((e) => e.value.level.index >= SeverityLevel.level2.index)
        .take(_maxFocus)
        .map((e) => e.key)
        .toList();
    if (raised.isNotEmpty) return raised;
    return sorted.take(2).map((e) => e.key).toList();
  }

  bool _adhdAtLevel3(AssessmentResult r) =>
      [SymptomCategory.inattention, SymptomCategory.hyperactivity].any(
        (c) => r.byCategory[c]?.level == SeverityLevel.level3,
      );
}