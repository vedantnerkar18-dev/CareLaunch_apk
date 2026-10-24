import '../models/severity_level.dart';

/// Everything the engine knows about one score.
class FuzzyResult {
  final double score; // 0-100
  final double low;
  final double moderate;
  final double high;
  final SeverityLevel level;

  const FuzzyResult({
    required this.score,
    required this.low,
    required this.moderate,
    required this.high,
    required this.level,
  });

    /// Same scores, different level (used when a domain rule adjusts the result).
    FuzzyResult withLevel(SeverityLevel newLevel) => FuzzyResult(
        score: score,
        low: low,
        moderate: moderate,
        high: high,
        level: newLevel,
      );
}

/// Pure Dart: no Flutter imports, so it is easy to test.
class FuzzyEngine {
  const FuzzyEngine();

  // Membership functions: each returns 0.0 to 1.0
  double low(double x) {
    if (x >= 40) return 0;
    return (40 - x) / 40;
  }

  double moderate(double x) {
    if (x <= 30 || x >= 70) return 0;
    if (x <= 50) return (x - 30) / 20;
    return (70 - x) / 20;
  }

  double high(double x) {
    if (x <= 60) return 0;
    return (x - 60) / 40;
  }

  /// Each answer is worth 1, 2 or 3 points. Converts a raw total to 0-100.
  double normalize(int rawTotal, int questionCount) {
    final score = (rawTotal - questionCount) / (questionCount * 2) * 100;
    return score.clamp(0, 100).toDouble();
  }

  /// Maximum membership principle. Ties go to the higher level (safer).
  FuzzyResult classify(double score) {
    final l = low(score);
    final m = moderate(score);
    final h = high(score);

    SeverityLevel level;
    if (h >= m && h >= l) {
      level = SeverityLevel.level3;
    } else if (m >= l) {
      level = SeverityLevel.level2;
    } else {
      level = SeverityLevel.level1;
    }

    return FuzzyResult(
        score: score, low: l, moderate: m, high: h, level: level);
  }
}