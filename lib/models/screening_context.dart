/// How long the worries have been going on.
enum ConcernDuration { underTwoWeeks, twoWeeksToSixMonths, sixMonthsPlus }

/// Where the behaviours are seen (home only, or home and school/elsewhere).
enum ConcernSettings { oneSetting, multipleSettings }

/// How much it gets in the way of school, friendships and daily routine.
enum DailyImpact { little, some, major }

/// The extra (unscored) answers that give the symptom scores their context.
class ScreeningContext {
  final bool mobileConcern;
  final ConcernDuration duration;
  final ConcernSettings settings;
  final DailyImpact impact;

  /// True if the child has talked about wanting to die or hurting themselves.
  final bool safetyConcern;

  const ScreeningContext({
    required this.mobileConcern,
    required this.duration,
    required this.settings,
    required this.impact,
    required this.safetyConcern,
  });

  ScreeningContext copyWith({
    bool? mobileConcern,
    ConcernDuration? duration,
    ConcernSettings? settings,
    DailyImpact? impact,
    bool? safetyConcern,
  }) =>
      ScreeningContext(
        mobileConcern: mobileConcern ?? this.mobileConcern,
        duration: duration ?? this.duration,
        settings: settings ?? this.settings,
        impact: impact ?? this.impact,
        safetyConcern: safetyConcern ?? this.safetyConcern,
      );
}