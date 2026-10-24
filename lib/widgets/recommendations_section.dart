import 'package:flutter/material.dart';

import '../data/recommendation_data.dart';
import '../logic/assessment_scorer.dart';
import '../logic/recommendation_engine.dart';
import '../utils/launcher.dart';

/// The three levels of help on the result screen:
/// Level 1 home tips, Level 2 videos and shopping, Level 3 specialists + helplines.
class RecommendationsSection extends StatefulWidget {
  final AssessmentResult result;
  final int? age;

  const RecommendationsSection({
    super.key,
    required this.result,
    required this.age,
  });

  @override
  State<RecommendationsSection> createState() => _RecommendationsSectionState();
}

class _RecommendationsSectionState extends State<RecommendationsSection> {
  final _pincode = TextEditingController();
  String? _pincodeError;

  @override
  void dispose() {
    _pincode.dispose();
    super.dispose();
  }

  void _findSpecialist(String specialist) {
    final code = _pincode.text.trim();
    if (!Launcher.isValidPincode(code)) {
      setState(() => _pincodeError = 'Enter a valid 6-digit pincode');
      return;
    }
    setState(() => _pincodeError = null);
    Launcher.open(context, Launcher.specialistsNear(specialist, code));
  }

  @override
  Widget build(BuildContext context) {
    final recs = const RecommendationEngine().build(widget.result, widget.age);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(theme, 'What you can try at home',
            'Ideas for ages ${recs.ageGroup.label}'),
        for (final group in recs.tips)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.category.label,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  for (final tip in group.tips)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2, right: 8),
                            child: Icon(Icons.check_circle_outline, size: 18),
                          ),
                          Expanded(child: Text(tip)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        if (recs.showGuided) ...[
          const SizedBox(height: 12),
          _heading(theme, 'Guided support',
              'Opens a search on YouTube or Google. We do not pick specific videos or products.'),
          for (final v in recs.videos)
            _LinkTile(
              icon: Icons.play_circle_outline,
              label: v.label,
              hint: 'Watch videos',
              onTap: () => Launcher.open(context, Launcher.youtubeSearch(v.query)),
            ),
          for (final s in recs.shopping)
            _LinkTile(
              icon: Icons.shopping_bag_outlined,
              label: s.label,
              hint: 'See products',
              onTap: () =>
                  Launcher.open(context, Launcher.shoppingSearch(s.query)),
            ),
        ],
        if (recs.showSpecialists) ...[
          const SizedBox(height: 12),
          _heading(theme, 'Talk to a specialist',
              'Enter your pincode to see nearby professionals on Google Maps.'),
          TextField(
            controller: _pincode,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'Pincode',
              border: const OutlineInputBorder(),
              errorText: _pincodeError,
            ),
            onChanged: (_) {
              if (_pincodeError != null) setState(() => _pincodeError = null);
            },
          ),
          for (final s in recs.specialists)
            _LinkTile(
              icon: Icons.location_on_outlined,
              label: s.label,
              hint: 'Find near me',
              onTap: () => _findSpecialist(s.query),
            ),
        ],
        if (recs.showHelplines) ...[
          const SizedBox(height: 12),
          _heading(theme, 'Helplines', 'Tap a number to call.'),
          for (final h in helplines)
            _LinkTile(
              icon: Icons.call,
              label: '${h.name}: ${h.number}',
              hint: h.note,
              onTap: () => Launcher.open(
                context,
                Launcher.call(h.number),
                fallbackMessage:
                    'Could not start a call here. Please dial ${h.number} from your phone.',
              ),
            ),
        ],
      ],
    );
  }

  Widget _heading(ThemeData theme, String title, String subtitle) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            Text(subtitle, style: theme.textTheme.bodySmall),
          ],
        ),
      );
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(hint),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: onTap,
      ),
    );
  }
}