enum SeverityLevel {
  level1('Level 1', 'Support at home'),
  level2('Level 2', 'Guided support'),
  level3('Level 3', 'Consult a specialist');

  final String title;
  final String meaning;
  const SeverityLevel(this.title, this.meaning);
}