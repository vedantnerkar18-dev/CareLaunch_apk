import '../models/question.dart';
import '../models/symptom_category.dart';

const _frequency = ['Rarely', 'Sometimes', 'Often'];
const _intensity = ['Mild', 'Moderate', 'Severe'];

const List<Question> questionBank = [
  Question(id: 1, text: 'How often does your child have sweaty palms?', category: SymptomCategory.anxiety, options: _frequency),
  Question(id: 2, text: 'How often does your child seem scared or nervous?', category: SymptomCategory.anxiety, options: _frequency),
  Question(id: 3, text: 'How often does your child seem restless?', category: SymptomCategory.anxiety, options: _frequency),
  Question(id: 4, text: 'How often does your child feel short of breath?', category: SymptomCategory.anxiety, options: ['Rarely', 'Weekly', 'Daily']),
  Question(id: 5, text: 'How strong is your child\'s shivering or trembling?', category: SymptomCategory.anxiety, options: _intensity),
  Question(id: 6, text: 'How often is your child easily distracted?', category: SymptomCategory.inattention, options: _frequency),
  Question(id: 7, text: 'How much difficulty does your child have concentrating?', category: SymptomCategory.inattention, options: _intensity),
  Question(id: 8, text: 'How often is your child hyperactive or fidgety?', category: SymptomCategory.hyperactivity, options: _frequency),
  Question(id: 9, text: 'How often does your child overreact to small issues?', category: SymptomCategory.hyperactivity, options: _frequency),
  Question(id: 10, text: 'How often is your child moody or irritable?', category: SymptomCategory.emotional, options: _frequency),
  Question(id: 11, text: 'Has your child lost interest in things they used to enjoy?', category: SymptomCategory.emotional, options: ['No', 'Sometimes', 'Yes']),
  Question(id: 12, text: 'How often does your child seem unusually tired?', category: SymptomCategory.sleep, options: _frequency),
  Question(id: 13, text: 'How often does your child have trouble sleeping?', category: SymptomCategory.sleep, options: ['Rarely', 'Sometimes', 'Frequently']),
];