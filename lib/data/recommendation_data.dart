import '../models/age_group.dart';
import '../models/symptom_category.dart';

/// A search the parent can open. We store only the topic, never a link,
/// so nothing here can go out of date or point to a video we have not checked.
class SearchIdea {
  final String label;
  final String topic; // the age phrase is added to the end when searching
  const SearchIdea(this.label, this.topic);
}

/// Level 1: home tips, two per category and age band.
const Map<SymptomCategory, Map<AgeGroup, List<String>>> homeTips = {
  SymptomCategory.anxiety: {
    AgeGroup.young: [
      'Practise "smell the flower, blow out the candle" breathing together: '
          'a slow breath in through the nose, a slow breath out through the mouth.',
      'Help your child name the worry and draw it. Keep daily routines '
          'predictable so the day feels safe.',
    ],
    AgeGroup.middle: [
      'Teach slow belly breathing: in for 4 counts, out for 6. Practise when '
          'your child is calm so it is easier to use when worried.',
      'Listen first when a worry comes up, before offering solutions.',
    ],
    AgeGroup.older: [
      'Encourage a short daily wind-down such as a walk, music or writing '
          'worries in a journal.',
      'Let your child know worries are common and that you are there to talk, '
          'without pushing for answers.',
    ],
  },
  SymptomCategory.inattention: {
    AgeGroup.young: [
      'Give one small step at a time, and use a picture checklist for routines '
          'like getting ready for school.',
      'Set up a quiet, uncluttered spot for homework, with short 10-minute '
          'stretches and a movement break.',
    ],
    AgeGroup.middle: [
      'Use a visual timer for homework: 15 to 20 minutes of work, then a '
          '5-minute break.',
      'Give instructions one at a time and ask your child to say them back.',
    ],
    AgeGroup.older: [
      'Plan the week together with a simple planner or phone reminders.',
      'Keep phones out of reach during study blocks, and follow each block '
          'with a short break.',
    ],
  },
  SymptomCategory.hyperactivity: {
    AgeGroup.young: [
      'Make time for active play every day (running, jumping, the playground), '
          'especially before sitting tasks.',
      'Give a clear, calm "job" such as helping set the table, so energy has '
          'a useful outlet.',
    ],
    AgeGroup.middle: [
      'Offer a daily sport or active hobby, and add short movement breaks '
          'between tasks.',
      'Practise a "stop and count to five" pause before reacting, and praise '
          'your child when they manage it.',
    ],
    AgeGroup.older: [
      'Regular exercise such as cycling, swimming or team sports can help '
          'channel energy and improve focus.',
      'Agree on a signal for when your child needs a break, and praise effort '
          'rather than only results.',
    ],
  },
  SymptomCategory.emotional: {
    AgeGroup.young: [
      'Use a feelings chart with faces so your child can point to how they feel.',
      'Set aside a few minutes of one-to-one time every day, and stay calm '
          'when feelings get big.',
    ],
    AgeGroup.middle: [
      'Name feelings out loud ("You seem frustrated") and talk about what has '
          'helped before.',
      'Keep regular meals, play and sleep. Tired or hungry children find '
          'feelings harder to manage.',
    ],
    AgeGroup.older: [
      'Chat side by side (on a walk or a drive) rather than face to face. '
          'It is often easier to open up that way.',
      'Respect their privacy but stay available, and notice changes in '
          'friends, interests or appetite.',
    ],
  },
  SymptomCategory.sleep: {
    AgeGroup.young: [
      'Keep the same bedtime and wake-up time every day, with a calm routine: '
          'bath, story, lights low.',
      'Switch screens off an hour before bed and charge devices outside the '
          'bedroom.',
    ],
    AgeGroup.middle: [
      'Wind down for 30 to 60 minutes before bed with reading, quiet music or '
          'light stretching.',
      'Avoid sugary drinks and heavy meals late in the evening, and keep the '
          'room dark and cool.',
    ],
    AgeGroup.older: [
      'Keep a steady sleep schedule, including weekends, and keep phones out '
          'of bed.',
      'Limit tea, cola and energy drinks in the afternoon and evening.',
    ],
  },
};

/// Level 2: video topics (opened as a YouTube search).
const Map<SymptomCategory, List<SearchIdea>> videoIdeas = {
  SymptomCategory.anxiety: [
    SearchIdea('Calm breathing exercises', 'breathing exercises for'),
    SearchIdea('Relaxation activities', 'relaxation activities for anxious'),
  ],
  SymptomCategory.inattention: [
    SearchIdea('Focus-building activities', 'focus and attention activities for'),
    SearchIdea('Homework routines', 'homework routine tips for'),
  ],
  SymptomCategory.hyperactivity: [
    SearchIdea('Movement breaks', 'indoor movement break activities for'),
    SearchIdea('Kids yoga', 'yoga for'),
  ],
  SymptomCategory.emotional: [
    SearchIdea('Talking about feelings', 'how to talk about feelings with'),
    SearchIdea('Mood-lifting activities', 'fun mood boosting activities for'),
  ],
  SymptomCategory.sleep: [
    SearchIdea('Bedtime wind-down', 'bedtime relaxation story for'),
    SearchIdea('Healthy sleep routine', 'healthy sleep routine for'),
  ],
};

/// Level 2: things that may help at home (opened as a Google Shopping search).
const Map<SymptomCategory, List<SearchIdea>> shoppingIdeas = {
  SymptomCategory.anxiety: [
    SearchIdea('Calming sensory toys', 'calming sensory toys for'),
    SearchIdea('Books about worries', 'books about worries for'),
  ],
  SymptomCategory.inattention: [
    SearchIdea('Visual timers', 'visual timer for'),
    SearchIdea('Focus puzzles', 'focus building puzzles for'),
  ],
  SymptomCategory.hyperactivity: [
    SearchIdea('Quiet fidget toys', 'quiet fidget toys for'),
    SearchIdea('Indoor active play', 'indoor active play equipment for'),
  ],
  SymptomCategory.emotional: [
    SearchIdea('Feelings chart', 'feelings chart for'),
    SearchIdea('Journals', 'journal for'),
  ],
  SymptomCategory.sleep: [
    SearchIdea('Night lights', 'night light for'),
    SearchIdea('Bedtime story books', 'bedtime story books for'),
  ],
};

/// Level 3: helplines. Numbers checked October 2026.
class Helpline {
  final String name;
  final String number;
  final String note;
  const Helpline(this.name, this.number, this.note);
}

const List<Helpline> helplines = [
  Helpline('Tele-MANAS', '14416', 'Free mental health support, 24 hours'),
  Helpline('CHILDLINE', '1098', 'Free helpline for children and their families'),
  Helpline('Emergency', '112', 'If your child is in immediate danger'),
];