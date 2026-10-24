/// Tips and searches are written for three age bands, not for every year.
enum AgeGroup {
  young('5 to 8', 'kids aged 5 to 8'),
  middle('9 to 11', 'kids aged 9 to 11'),
  older('12 to 14', 'kids aged 12 to 14');

  final String label;

  /// Added to the end of search queries, e.g. "breathing exercises for kids aged 5 to 8".
  final String searchPhrase;
  const AgeGroup(this.label, this.searchPhrase);

  /// A missing age falls back to the youngest band (the most cautious tips).
  static AgeGroup fromAge(int? age) {
    if (age == null || age <= 8) return AgeGroup.young;
    if (age <= 11) return AgeGroup.middle;
    return AgeGroup.older;
  }
}