/// A note the result screen shows next to the levels.
/// Messages are written for parents and never claim a diagnosis.
enum ResultFlag {
  screenTimeTip(
    'Screens close to bedtime can make sleep harder. Try switching them off '
    'a little earlier each night, working up to an hour before bed.',
  ),
  sleepScreenLink(
    'Sleep is the main concern here, and phone use may be playing a part. '
    'Start with a screen-free wind-down routine before bed.',
  ),
  sleepHomeRoutine(
    'Sleep is the main concern here. A calm, regular bedtime routine often '
    'helps. If it continues for a few weeks, mention it to your child\'s doctor.',
  ),
  sleepWorryLinked(
    'Trouble sleeping can be linked to worries. A calming evening routine '
    'may help with both.',
  ),
  checkPhysicalHealth(
    'Some of these signs (such as breathlessness, sweating or tiredness) can '
    'have physical causes. A check-up with your child\'s doctor is a sensible '
    'first step.',
  ),
  adhdNotYetPervasive(
    'These behaviours may be situational. They matter more when they last '
    '6 months or longer and show up in more than one place, such as home and '
    'school. Ask the teacher what they see, and check again in a few weeks.',
  ),
  anxietyAdhdOverlap(
    'Anxiety and attention difficulties can look alike and often occur '
    'together. A professional can help tell them apart.',
  ),
  lowMoodWarning(
    'Loss of interest together with irritability, lasting for weeks, can be '
    'a sign of low mood in children. Please talk to your child\'s doctor or '
    'a counsellor.',
  ),
  lowMoodWatch(
    'Mood dips are common. If this lasts two weeks or more, please talk to '
    'your child\'s doctor.',
  ),
  safetyAlert(
    'You told us your child has talked about wanting to die or hurting '
    'themselves. Please take this seriously and get help today. Call '
    'Tele-MANAS on 14416 (free, 24 hours), or 112 if your child is in '
    'immediate danger.',
  );

  final String message;
  const ResultFlag(this.message);
}