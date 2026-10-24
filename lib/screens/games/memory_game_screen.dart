import 'package:flutter/material.dart';

import '../../games/memory_logic.dart';
import '../../widgets/zone_widgets.dart';

const _symbols = <IconData>[
  Icons.favorite, Icons.star, Icons.pets, Icons.local_florist, Icons.wb_sunny,
  Icons.cloud, Icons.music_note, Icons.cake, Icons.eco, Icons.beach_access,
];
const _colours = <Color>[
  Color(0xFFE57373), Color(0xFFF9A825), Color(0xFF8D6E63), Color(0xFFBA68C8),
  Color(0xFFFB8C00), Color(0xFF64B5F6), Color(0xFF4DB6AC), Color(0xFFF06292),
  Color(0xFF66BB6A), Color(0xFF26C6DA),
];

/// Concentration: find the matching pairs. No timer, no pressure.
class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  int _pairs = 6;
  late MemoryGame _game = MemoryGame(_pairs);

  void _restart([int? pairs]) {
    setState(() {
      if (pairs != null) _pairs = pairs;
      _game = MemoryGame(_pairs);
    });
  }

  void _tap(int index) {
    final outcome = _game.flip(index);
    if (outcome == FlipOutcome.ignored) return;
    setState(() {});
    if (outcome == FlipOutcome.mismatch) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(_game.hideMismatch);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columns = _pairs == 10 ? 5 : 4;

    return GameFrame(
      title: 'Memory Match',
      children: [
        const Text('Turn over two cards at a time and find the matching pairs. '
            'Take your time.'),
        const SizedBox(height: 12),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 6, label: Text('Easy')),
            ButtonSegment(value: 8, label: Text('Medium')),
            ButtonSegment(value: 10, label: Text('Hard')),
          ],
          selected: {_pairs},
          onSelectionChanged: (s) => _restart(s.first),
        ),
        const SizedBox(height: 12),
        Text('Moves: ${_game.moves}', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            for (var i = 0; i < _game.cards.length; i++)
              _CardTile(card: _game.cards[i], onTap: () => _tap(i)),
          ],
        ),
        if (_game.isComplete)
          Card(
            margin: const EdgeInsets.only(top: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Well done!', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('You found every pair in ${_game.moves} moves.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _restart,
                    child: const Text('Play again'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CardTile extends StatelessWidget {
  final MemoryCard card;
  final VoidCallback onTap;
  const _CardTile({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shown = card.faceUp || card.matched;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: shown
              ? (card.matched ? const Color(0xFFE8F5E9) : Colors.white)
              : theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: shown ? const Color(0xFFDCE8EC) : theme.colorScheme.primary,
          ),
        ),
        child: Center(
          child: shown
              ? Icon(_symbols[card.pairId], color: _colours[card.pairId], size: 32)
              : const Icon(Icons.help_outline, color: Colors.white70),
        ),
      ),
    );
  }
}