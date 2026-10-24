import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/result_flag.dart';
import '../models/severity_level.dart';
import '../models/symptom_category.dart';
import '../state/assessment_controller.dart';
import '../widgets/recommendations_section.dart';
import 'child_zone_screen.dart';

Color _levelColor(SeverityLevel level) {
  switch (level) {
    case SeverityLevel.level1:
      return Colors.green.shade700;
    case SeverityLevel.level2:
      return Colors.orange.shade800;
    case SeverityLevel.level3:
      return Colors.red.shade700;
  }
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AssessmentController>();
    final result = controller.result;
    final theme = Theme.of(context);

    if (result == null) {
      return const Scaffold(body: Center(child: Text('No result yet.')));
    }

    final hasAlert = result.flags.contains(ResultFlag.safetyAlert);
    final notes =
        result.flags.where((f) => f != ResultFlag.safetyAlert).toList();
    final overallColor = _levelColor(result.overall.level);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your results'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (hasAlert)
                  _InfoCard(
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red.shade700,
                    background: Colors.red.shade50,
                    text: ResultFlag.safetyAlert.message,
                  ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: overallColor, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overall', style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(
                        result.overall.level.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: overallColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        result.overall.level.meaning,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (controller.concerns.isNotEmpty) ...[
                  Text('What you told us was on your mind',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final cat in SymptomCategory.values
                      .where(controller.concerns.contains))
                    _CategoryRow(
                      label: cat.label,
                      level: result.byCategory[cat]!.level,
                    ),
                  const SizedBox(height: 24),
                ],
                Text('By area', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final entry in result.byCategory.entries)
                  _CategoryRow(
                    label: entry.key.label,
                    level: entry.value.level,
                  ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Good to know', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final flag in notes)
                    _InfoCard(
                      icon: Icons.info_outline,
                      color: theme.colorScheme.primary,
                      background: theme.colorScheme.surfaceContainerHighest,
                      text: flag.message,
                    ),
                ],
                const SizedBox(height: 24),
                RecommendationsSection(result: result, age: controller.age),
                const SizedBox(height: 24),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChildZoneScreen()),
                  ),
                  icon: const Icon(Icons.spa_outlined),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Open the Child Zone'),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'CareLaunch is a screening and awareness tool. It cannot '
                  'diagnose any condition. Please speak to a doctor or '
                  'qualified professional about any concern.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    controller.reset();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Back to my children'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String label;
  final SeverityLevel level;

  const _CategoryRow({required this.label, required this.level});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _levelColor(level),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              level.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String text;

  const _InfoCard({
    required this.icon,
    required this.color,
    required this.background,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}