import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/child_profile.dart';
import '../models/screening_record.dart';
import '../services/profile_repository.dart';
import '../utils/formatters.dart';

/// Every saved check-in for one child, newest first.
class HistoryScreen extends StatelessWidget {
  final ChildProfile child;
  const HistoryScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ProfileRepository>();
    return Scaffold(
      appBar: AppBar(title: Text('${child.name}\'s check-ins')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: StreamBuilder<List<ScreeningRecord>>(
              stream: repo.watchScreenings(child.id),
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Could not load the history. Please try again.'),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final records = snap.data!;
                if (records.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No check-ins yet. After you finish one, it appears here '
                      'so you can see how things change over time.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [for (final r in records) _RecordTile(record: r)],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final ScreeningRecord record;
  const _RecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(formatDate(record.createdAt)),
        subtitle: Text(
          '${record.overall.title}: ${record.overall.meaning}'
          '${record.ageAtScreening > 0 ? '  |  Age ${record.ageAtScreening}' : ''}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in record.categoryLevels.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text(e.key.label)),
                  Text(e.value.title),
                ],
              ),
            ),
          if (record.safetyAlert)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('A safety concern was reported in this check-in.'),
            ),
        ],
      ),
    );
  }
}