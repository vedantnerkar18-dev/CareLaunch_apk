import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/child_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_repository.dart';
import 'add_child_screen.dart';
import 'history_screen.dart';

/// The "Check-in" tab: the caregiver's children, with a check-in button each.
class ChildrenScreen extends StatelessWidget {
  final void Function(ChildProfile child) onStartCheckIn;
  final VoidCallback onLearnMore;

  const ChildrenScreen({
    super.key,
    required this.onStartCheckIn,
    required this.onLearnMore,
  });

  Future<void> _confirmRemove(BuildContext context, ChildProfile child) async {
    final repo = context.read<ProfileRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove ${child.name}?'),
        content: const Text(
          'This permanently deletes this profile and all of their check-ins. '
          'It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await repo.deleteChild(child.id);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not remove. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final repo = context.read<ProfileRepository>();
    final name = auth.currentUser?.displayName ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('My children')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddChildScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add child'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: StreamBuilder<List<ChildProfile>>(
              stream: repo.watchChildren(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Could not load your children. Please check your '
                      'connection and try again.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final children = snap.data!;
                final today = DateTime.now();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    Text(
                      name.isEmpty ? 'Hello' : 'Hello, $name',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (children.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            const Text(
                              'Add your child to start a check-in. Each child '
                              'has their own profile and history.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: onLearnMore,
                              icon: const Icon(Icons.info_outline),
                              label: const Text('How does CareLaunch work?'),
                            ),
                          ],
                        ),
                      ),
                    for (final child in children)
                      _ChildCard(
                        child: child,
                        today: today,
                        onStart: () => onStartCheckIn(child),
                        onHistory: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HistoryScreen(child: child),
                          ),
                        ),
                        onRemove: () => _confirmRemove(context, child),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildProfile child;
  final DateTime today;
  final VoidCallback onStart;
  final VoidCallback onHistory;
  final VoidCallback onRemove;

  const _ChildCard({
    required this.child,
    required this.today,
    required this.onStart,
    required this.onHistory,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final age = child.ageOn(today);
    final canScreen = child.canScreenOn(today);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.child_care)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child.name, style: theme.textTheme.titleMedium),
                      Text(
                        [
                          'Age $age',
                          if (child.gender != null) child.gender!,
                        ].join(' | '),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (_) => onRemove(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'remove', child: Text('Remove child')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!canScreen)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Check-ins are designed for ages 5 to 14. Past check-ins '
                  'are still available.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: canScreen ? onStart : null,
                    child: const Text('Start check-in'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: onHistory, child: const Text('History')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}