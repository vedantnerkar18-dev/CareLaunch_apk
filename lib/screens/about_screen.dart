import 'package:flutter/material.dart';

import '../data/recommendation_data.dart';

/// "What is CareLaunch?" Explains the platform. At the bottom, the parent can
/// choose to continue (the screen closes with `true`) or go back.
class AboutScreen extends StatelessWidget {
  /// The text on the main button, e.g. "Start a check-in".
  final String ctaLabel;

  /// When set (the About tab), the button calls this instead of closing the
  /// screen, and "Maybe later" is hidden.
  final VoidCallback? onCta;

  const AboutScreen({super.key, required this.ctaLabel, this.onCta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tele = helplines.firstWhere((h) => h.name == 'Tele-MANAS');
    final emergency = helplines.firstWhere((h) => h.name == 'Emergency');

    return Scaffold(
      appBar: AppBar(title: const Text('About CareLaunch')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Icon(Icons.rocket_launch,
                    size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  'Understanding your child, one check-in at a time',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const _Section(
                  icon: Icons.info_outline,
                  title: 'What is CareLaunch?',
                  children: [
                    Text(
                      'CareLaunch is a screening and guidance app for parents '
                      'and caregivers of children aged 5 to 14. It helps you '
                      'notice early signs of emotional and behavioural '
                      'difficulties, and shows you what to do next.',
                    ),
                    SizedBox(height: 8),
                    Text(
                      'It looks at five areas: worries and nerves, focus, '
                      'energy and restlessness, mood and feelings, and sleep '
                      'and tiredness.',
                    ),
                  ],
                ),
                const _Section(
                  icon: Icons.route_outlined,
                  title: 'What does it do?',
                  children: [
                    _Step(1, 'You answer quick questions',
                        'About 18 questions, one at a time. It takes 3 to 5 minutes.'),
                    _Step(2, 'You see a clear result',
                        'Each area, and your child overall, is placed in one of three levels.'),
                    _Step(3, 'You get guidance that fits',
                        'Home tips for your child\'s age, helpful videos and products to look at, '
                        'and nearby specialists and helplines when they are needed.'),
                    _Step(4, 'You keep a history',
                        'Every check-in is saved for your child, so you can see how things change. '
                        'The Child Zone has calming activities for your child to try.'),
                  ],
                ),
                const _Section(
                  icon: Icons.stairs_outlined,
                  title: 'The three levels',
                  children: [
                    _Level(Color(0xFF2E7D32), 'Level 1: Support at home',
                        'Simple things to try at home.'),
                    _Level(Color(0xFFEF6C00), 'Level 2: Guided support',
                        'More structured help, such as videos and activities.'),
                    _Level(Color(0xFFC62828), 'Level 3: Consult a specialist',
                        'We suggest talking to a doctor or psychologist, and help you find one.'),
                  ],
                ),
                const _Section(
                  icon: Icons.family_restroom_outlined,
                  title: 'Who is it for?',
                  children: [
                    Text(
                      'Parents, guardians and caregivers of a child aged 5 to '
                      '14, especially if you are wondering whether something '
                      'you have noticed is worth acting on.',
                    ),
                  ],
                ),
                _Section(
                  icon: Icons.health_and_safety_outlined,
                  title: 'What CareLaunch is not',
                  children: [
                    const Text(
                      'CareLaunch is a screening tool, not a diagnosis. Only '
                      'a qualified doctor or psychologist can diagnose '
                      'anything, and CareLaunch does not replace one.',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If your child may be in danger, call ${emergency.number} '
                      'right away. For free support at any time, call '
                      '${tele.name} on ${tele.number}.',
                    ),
                  ],
                ),
                const _Section(
                  icon: Icons.lock_outline,
                  title: 'Your privacy',
                  children: [
                    Text(
                      'We save your child\'s first name, date of birth and '
                      'the result levels of each check-in. We do not save '
                      'each individual answer. Only your account can open '
                      'this information, and you can remove a child and '
                      'their history at any time.',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: onCta ?? () => Navigator.pop(context, true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(ctaLabel),
                  ),
                ),
                if (onCta == null)
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Maybe later'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  const _Section(
      {required this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String title;
  final String text;
  const _Step(this.number, this.title, this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 12, child: Text('$number', style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Level extends StatelessWidget {
  final Color color;
  final String title;
  final String text;
  const _Level(this.color, this.title, this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}