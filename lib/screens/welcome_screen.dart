import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/assessment_controller.dart';
import 'assessment_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AssessmentController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 24),
                Icon(Icons.rocket_launch,
                    size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'CareLaunch',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'A calm, simple check-in for parents and caregivers of '
                  'children aged 5 to 14.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                Text('How old is your child?',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var years = 5; years <= 14; years++)
                      ChoiceChip(
                        label: Text('$years'),
                        selected: controller.age == years,
                        onSelected: (_) => controller.setAge(years),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: controller.age == null
                      ? null
                      : () {
                          controller.begin();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AssessmentScreen(),
                            ),
                          );
                        },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Start'),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'CareLaunch is a screening and awareness tool. It cannot '
                  'diagnose any condition and does not replace a doctor or '
                  'counsellor.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}