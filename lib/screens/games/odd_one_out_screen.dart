import 'package:flutter/material.dart';

import '../../games/odd_one_logic.dart';
import '../../widgets/zone_widgets.dart';

/// (filled icon, outline icon): look-alikes, so the child has to look closely.
const _pairs = <(IconData, IconData)>[
  (Icons.star, Icons.star_border),
  (Icons.favorite, Icons.favorite_border),
  (Icons.cloud, Icons.cloud_outlined),
  (Icons.bookmark, Icons.bookmark_border),
  (Icons.circle, Icons.circle_outlined),
  (Icons.thumb_up, Icons.thumb_up_outlined),
];

/// Concentration: spot the tile that is different.
class OddOneOutScreen extends StatefulWidget {
  const OddOneOutScreen({super.key});

  @override
  State<OddOneOutScreen> createState() => _OddOneOutScreenState();
}

class _OddOneOutScreenState extends State<OddOneOutScreen> {
  OddOneOutGame _game = OddOneOutGame();
  String _message = 'Find the one that is different.';

  void _tap(int index) {
    final correct = _game.tap(index);
    setState(() {
      _message = correct
          ? 'Great spotting! Here is the next one.'
          : 'Not that one. Look again, take your time.';
    });
  }

  void _restart() => setState(() {
        _game = OddOneOutGame();
        _message = 'Find the one that is different.';
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final round = _game.round;
    final pair = _pairs[round.kind];
    final base = round.oddIsOutline ? pair.$1 : pair.$2;
    final odd = round.oddIsOutline ? pair.$2 : pair.$1;

    return GameFrame(
      title: 'Odd One Out',
      children: [
        Text(_message, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Found so far: ${_game.found}'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, c) {
            final tile = c.maxWidth / round.gridSize;
            return GridView.count(
              crossAxisCount: round.gridSize,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < round.tileCount; i++)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _tap(i),
                    child: Center(
                      child: Icon(
                        i == round.oddIndex ? odd : base,
                        size: tile * 0.55,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        TextButton(onPressed: _restart, child: const Text('Start again')),
      ],
    );
  }
}