import 'dart:math';

class OddOneRound {
  final int gridSize;
  final int oddIndex; // which tile is different
  final int kind; // which pair of look-alike icons
  final bool oddIsOutline; // the odd tile is the outline version (or the filled one)

  const OddOneRound({
    required this.gridSize,
    required this.oddIndex,
    required this.kind,
    required this.oddIsOutline,
  });

  int get tileCount => gridSize * gridSize;
}

/// "Find the one that is different". The grid grows as the child succeeds.
class OddOneOutGame {
  static const int kinds = 6;
  final Random _random;
  int found = 0;
  late OddOneRound round;

  OddOneOutGame({Random? random}) : _random = random ?? Random() {
    round = _newRound();
  }

  int get gridSize => min(6, 3 + found ~/ 3);

  OddOneRound _newRound() {
    final size = gridSize;
    return OddOneRound(
      gridSize: size,
      oddIndex: _random.nextInt(size * size),
      kind: _random.nextInt(kinds),
      oddIsOutline: _random.nextBool(),
    );
  }

  /// Returns true if the tapped tile was the different one.
  bool tap(int index) {
    if (index != round.oddIndex) return false;
    found++;
    round = _newRound();
    return true;
  }
}