import '../models/step_def.dart';

/// The 5 extra (unscored) questions. ORDER MATTERS: the controller reads them
/// as mobile, duration, settings, impact, safety, and the options of the
/// middle three must stay in the same order as their enums
/// (ConcernDuration, ConcernSettings, DailyImpact).
const List<StepDef> contextSteps = [
  StepDef(
    prompt: 'Is your child\'s mobile or screen use a concern for you?',
    options: ['Yes', 'No'],
  ),
  StepDef(
    prompt: 'How long have these concerns been going on?',
    options: ['Less than 2 weeks', '2 weeks to 6 months', '6 months or more'],
  ),
  StepDef(
    prompt: 'Where do you notice them?',
    options: [
      'Mostly in one place',
      'In more than one place (for example home and school)',
    ],
  ),
  StepDef(
    prompt: 'How much do they affect school, friendships or daily routine?',
    options: ['Little or not at all', 'Somewhat', 'A lot'],
  ),
  StepDef(
    prompt:
        'Has your child said things like wanting to die, or talked about hurting themselves?',
    helper:
        'We ask everyone this one. If the answer is yes, we will show you where to get help right away.',
    options: ['No', 'Yes'],
  ),
];