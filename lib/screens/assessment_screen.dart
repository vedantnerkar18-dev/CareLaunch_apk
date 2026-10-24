import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/screening_record.dart';
import '../services/profile_repository.dart';
import '../state/assessment_controller.dart';
import '../widgets/rocket_progress.dart';
import 'result_screen.dart';

class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AssessmentController>();
    final step = c.currentStep;
    final picked = c.pickedForCurrent;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('CareLaunch')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RocketProgress(progress: c.progress),
                  Text(
                    'Step ${c.currentIndex + 1} of ${c.totalSteps}  |  ${c.sectionLabel}',
                    style: theme.textTheme.labelLarge,
                  ),
                  if (c.encouragement != null)
                    _EncouragementCard(message: c.encouragement!),
                  const SizedBox(height: 24),
                  Text(step.prompt, style: theme.textTheme.headlineSmall),
                  if (step.helper != null) ...[
                    const SizedBox(height: 8),
                    Text(step.helper!, style: theme.textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: [
                        for (var i = 0; i < step.options.length; i++)
                          _OptionTile(
                            label: step.options[i],
                            selected: picked == i,
                            onTap: () => c.select(i),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          if (c.currentIndex == 0) {
                            Navigator.pop(context);
                          } else {
                            c.back();
                          }
                        },
                        child: const Text('Back'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: picked == null
                            ? null
                            : () {
                                if (c.isLast) {
                                  c.finish();
                                  _saveHistory(context, c);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ResultScreen(),
                                    ),
                                  );
                                } else {
                                  c.next();
                                }
                              },
                        child: Text(c.isLast ? 'See results' : 'Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EncouragementCard extends StatelessWidget {
  final String message;
  const _EncouragementCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite_border, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (selected) Icon(Icons.check_circle, color: scheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Saves the finished check-in to the child's history. It runs in the
/// background: if it fails, a message appears on whichever screen is showing.
void _saveHistory(BuildContext context, AssessmentController c) {
  final child = c.child;
  final result = c.result;
  if (child == null || result == null) return;

  final messenger = ScaffoldMessenger.of(context);
  final record = ScreeningRecord.fromResult(
    result,
    age: c.age ?? child.ageOn(DateTime.now()),
  );
  context.read<ProfileRepository>().saveScreening(child.id, record).catchError(
    (Object _) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not save this check-in to the history.'),
        ),
      );
    },
  );
}