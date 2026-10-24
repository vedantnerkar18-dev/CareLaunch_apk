import 'package:flutter/material.dart';

import '../widgets/zone_widgets.dart';
import 'breathing_screen.dart';
import 'games/memory_game_screen.dart';
import 'games/mandala_screen.dart';
import 'games/odd_one_out_screen.dart';
import 'games/popit_screen.dart';
import 'music_screen.dart';

/// Calm, focus and play, grouped by what each activity is for.
class ChildZoneScreen extends StatelessWidget {
  const ChildZoneScreen({super.key});

  void _open(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Child Zone')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.spa,
                            size: 36, color: theme.colorScheme.onPrimaryContainer),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'A calm space to breathe, listen and play. '
                            'No scores to beat, no timers.',
                            style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ZoneSection(
                  icon: Icons.air,
                  title: 'Calm and relax',
                  subtitle: 'Slow things down',
                  tiles: [
                    ZoneTile(
                      icon: Icons.bubble_chart,
                      title: 'Breathing bubble',
                      subtitle: 'Follow the bubble to breathe slowly',
                      onTap: () => _open(context, const BreathingScreen()),
                    ),
                    ZoneTile(
                      icon: Icons.headphones,
                      title: 'Calming music',
                      subtitle: 'Soft sounds for calm, focus and sleep',
                      onTap: () => _open(context, const MusicScreen()),
                    ),
                  ],
                ),
                ZoneSection(
                  icon: Icons.center_focus_strong_outlined,
                  title: 'Focus and concentration',
                  subtitle: 'Gentle brain exercises',
                  tiles: [
                    ZoneTile(
                      icon: Icons.grid_view_rounded,
                      title: 'Memory match',
                      subtitle: 'Find the matching pairs',
                      onTap: () => _open(context, const MemoryGameScreen()),
                    ),
                    ZoneTile(
                      icon: Icons.search,
                      title: 'Odd one out',
                      subtitle: 'Spot the one that is different',
                      onTap: () => _open(context, const OddOneOutScreen()),
                    ),
                  ],
                ),
                ZoneSection(
                  icon: Icons.self_improvement,
                  title: 'Stress relief',
                  subtitle: 'Unwind with simple, soothing play',
                  tiles: [
                    ZoneTile(
                      icon: Icons.bubble_chart_outlined,
                      title: 'Calm pop-it',
                      subtitle: 'Pop the bubbles, one by one',
                      onTap: () => _open(context, const PopItScreen()),
                    ),
                    ZoneTile(
                      icon: Icons.palette_outlined,
                      title: 'Colour mandala',
                      subtitle: 'Fill in the shapes with colour',
                      onTap: () => _open(context, const MandalaScreen()),
                    ),
                  ],
                ),
                Text(
                  'These activities are for relaxation and fun. They are not '
                  'a treatment.',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}