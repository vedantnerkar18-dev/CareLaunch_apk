import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/zone_widgets.dart';

/// Stress relief: pop the bubbles, one tap at a time.
class PopItScreen extends StatefulWidget {
  const PopItScreen({super.key});

  @override
  State<PopItScreen> createState() => _PopItScreenState();
}

class _PopItScreenState extends State<PopItScreen> {
  static const int _cols = 5;
  static const int _rows = 6;
  static const _rowColours = <Color>[
    Color(0xFF80CBC4), Color(0xFF81D4FA), Color(0xFF9FA8DA),
    Color(0xFFCE93D8), Color(0xFFF48FB1), Color(0xFFFFCC80),
  ];

  final List<bool> _popped = List.filled(_cols * _rows, false);

  int get _count => _popped.where((p) => p).length;

  void _pop(int i) {
    if (_popped[i]) return;
    HapticFeedback.lightImpact();
    setState(() => _popped[i] = true);
  }

  void _reset() => setState(() => _popped.fillRange(0, _popped.length, false));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = _count == _popped.length;

    return GameFrame(
      title: 'Calm Pop-It',
      children: [
        const Text('Tap each bubble to pop it. Breathe slowly as you go.'),
        const SizedBox(height: 12),
        Text('Popped: $_count of ${_popped.length}',
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: _cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            for (var i = 0; i < _popped.length; i++)
              GestureDetector(
                onTap: () => _pop(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _popped[i]
                        ? _rowColours[i ~/ _cols].withValues(alpha: 0.25)
                        : _rowColours[i ~/ _cols],
                    border: Border.all(
                      color: _rowColours[i ~/ _cols],
                      width: _popped[i] ? 1 : 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (done)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'All popped. Nicely done. Take one slow, deep breath.',
              textAlign: TextAlign.center,
            ),
          ),
        OutlinedButton(onPressed: _reset, child: const Text('Reset bubbles')),
      ],
    );
  }
}