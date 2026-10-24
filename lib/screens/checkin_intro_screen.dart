import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/checkin_copy.dart';
import '../state/assessment_controller.dart';
import 'assessment_screen.dart';

/// "Before we begin": builds trust and sets expectations before question 1.
class CheckInIntroScreen extends StatelessWidget {
  const CheckInIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AssessmentController>();
    final theme = Theme.of(context);
    final name = c.child?.name ?? 'your child';

    return Scaffold(
      appBar: AppBar(title: const Text('Before we begin')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Icon(Icons.favorite, size: 44, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  'Let\'s check in on $name',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Taking a few minutes to notice how $name has been is a '
                  'caring thing to do. Here is what to expect.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                _InfoTile(
                  icon: Icons.timer_outlined,
                  title: 'About 3 to 5 minutes',
                  text: '${c.totalSteps} quick questions, one at a time. '
                      'Just tap the answer that fits best.',
                ),
                const _InfoTile(
                  icon: Icons.check_circle_outline,
                  title: 'No right or wrong answers',
                  text: 'Think about how your child has been lately. Most '
                      'parents notice some of these things now and then.',
                ),
                const _InfoTile(
                  icon: Icons.lock_outline,
                  title: 'Your answers stay private',
                  text: 'We save only the result levels in your child\'s '
                      'history, not each answer. Only your account can open them.',
                ),
                const _InfoTile(
                  icon: Icons.health_and_safety_outlined,
                  title: 'A guide, not a diagnosis',
                  text: 'CareLaunch cannot diagnose anything. It helps you '
                      'see what may need attention and what to try next.',
                ),
                const SizedBox(height: 20),
                Text('What has been on your mind about $name lately?',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Optional. Tap any that fit. This is not part of the '
                    'score. We will show it back to you with your results.',
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in concernChips.entries)
                      FilterChip(
                        label: Text(e.value),
                        selected: c.concerns.contains(e.key),
                        onSelected: (_) => c.toggleConcern(e.key),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AssessmentScreen()),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('I\'m ready'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _InfoTile({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}