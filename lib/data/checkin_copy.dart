import '../models/symptom_category.dart';

/// Friendly section names shown above each scored question.
const Map<SymptomCategory, String> sectionTitles = {
  SymptomCategory.anxiety: 'Worries and nerves',
  SymptomCategory.inattention: 'Focus',
  SymptomCategory.hyperactivity: 'Energy and restlessness',
  SymptomCategory.emotional: 'Mood and feelings',
  SymptomCategory.sleep: 'Sleep and tiredness',
};

/// The "what is on your mind?" choices on the intro screen.
const Map<SymptomCategory, String> concernChips = {
  SymptomCategory.anxiety: 'Worries or fears',
  SymptomCategory.inattention: 'Focus or concentration',
  SymptomCategory.hyperactivity: 'Restless or very energetic',
  SymptomCategory.emotional: 'Mood or big feelings',
  SymptomCategory.sleep: 'Sleep or tiredness',
};

const String contextSectionTitle = 'The bigger picture';