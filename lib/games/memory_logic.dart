import 'dart:math';

class MemoryCard {
  final int pairId;
  bool faceUp = false;
  bool matched = false;
  MemoryCard(this.pairId);
}

enum FlipOutcome { ignored, firstCard, match, mismatch }

/// Memory match with no timer. Pure Dart, so it can be unit tested.
class MemoryGame {
  final int pairs;
  final List<MemoryCard> cards;
  int moves = 0;
  int? _firstIndex;
  List<int> _pending = const [];

  MemoryGame(this.pairs, {Random? random})
      : cards = _deal(pairs, random ?? Random());

  static List<MemoryCard> _deal(int pairs, Random random) {
    final deck = [
      for (var i = 0; i < pairs; i++) ...[MemoryCard(i), MemoryCard(i)],
    ];
    deck.shuffle(random);
    return deck;
  }

  /// After a mismatch, taps are ignored until [hideMismatch] is called.
  bool get awaitingHide => _pending.isNotEmpty;
  bool get isComplete => cards.every((c) => c.matched);

  FlipOutcome flip(int index) {
    if (awaitingHide) return FlipOutcome.ignored;
    final card = cards[index];
    if (card.faceUp || card.matched) return FlipOutcome.ignored;

    card.faceUp = true;
    final first = _firstIndex;
    if (first == null) {
      _firstIndex = index;
      return FlipOutcome.firstCard;
    }

    moves++;
    _firstIndex = null;
    if (cards[first].pairId == card.pairId) {
      cards[first].matched = true;
      card.matched = true;
      return FlipOutcome.match;
    }
    _pending = [first, index];
    return FlipOutcome.mismatch;
  }

  void hideMismatch() {
    for (final i in _pending) {
      cards[i].faceUp = false;
    }
    _pending = const [];
  }
}