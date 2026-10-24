enum SymptomCategory {
  anxiety('Anxiety'),
  inattention('Inattention'),
  hyperactivity('Hyperactivity'),
  emotional('Emotional'),
  sleep('Sleep & fatigue');

  final String label;
  const SymptomCategory(this.label);
}