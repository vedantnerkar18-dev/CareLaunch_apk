import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:carelaunch/data/music_tracks.dart';
import 'package:carelaunch/games/mandala_logic.dart';
import 'package:carelaunch/games/memory_logic.dart';
import 'package:carelaunch/games/odd_one_logic.dart';

void main() {
  group('MemoryGame', () {
    test('deals every pair exactly twice', () {
      final g = MemoryGame(6, random: Random(1));
      expect(g.cards.length, 12);
      for (var id = 0; id < 6; id++) {
        expect(g.cards.where((c) => c.pairId == id).length, 2);
      }
    });

    /// Finds two cards that match, and two that do not.
    (int, int) matchingPair(MemoryGame g) {
      for (var i = 0; i < g.cards.length; i++) {
        for (var j = i + 1; j < g.cards.length; j++) {
          if (g.cards[i].pairId == g.cards[j].pairId) return (i, j);
        }
      }
      throw StateError('no pair');
    }

    (int, int) differentPair(MemoryGame g) {
      for (var j = 1; j < g.cards.length; j++) {
        if (g.cards[0].pairId != g.cards[j].pairId) return (0, j);
      }
      throw StateError('no different cards');
    }

    test('a match stays face up and counts one move', () {
      final g = MemoryGame(6, random: Random(2));
      final (a, b) = matchingPair(g);
      expect(g.flip(a), FlipOutcome.firstCard);
      expect(g.flip(b), FlipOutcome.match);
      expect(g.moves, 1);
      expect(g.cards[a].matched && g.cards[b].matched, isTrue);
    });

    test('a mismatch blocks taps until it is hidden', () {
      final g = MemoryGame(6, random: Random(3));
      final (a, b) = differentPair(g);
      g.flip(a);
      expect(g.flip(b), FlipOutcome.mismatch);
      final other = List.generate(g.cards.length, (i) => i)
          .firstWhere((i) => i != a && i != b);
      expect(g.flip(other), FlipOutcome.ignored);
      g.hideMismatch();
      expect(g.cards[a].faceUp || g.cards[b].faceUp, isFalse);
      expect(g.flip(other), FlipOutcome.firstCard);
    });

    test('tapping a face-up card does nothing', () {
      final g = MemoryGame(6, random: Random(4));
      g.flip(0);
      expect(g.flip(0), FlipOutcome.ignored);
    });

    test('the game completes when every pair is found', () {
      final g = MemoryGame(6, random: Random(5));
      expect(g.isComplete, isFalse);
      for (var id = 0; id < 6; id++) {
        final idx = [
          for (var i = 0; i < g.cards.length; i++)
            if (g.cards[i].pairId == id) i,
        ];
        g.flip(idx[0]);
        g.flip(idx[1]);
      }
      expect(g.isComplete, isTrue);
    });
  });

  group('OddOneOutGame', () {
    test('a right tap scores and starts a new round', () {
      final g = OddOneOutGame(random: Random(1));
      expect(g.tap(g.round.oddIndex), isTrue);
      expect(g.found, 1);
    });

    test('a wrong tap changes nothing', () {
      final g = OddOneOutGame(random: Random(1));
      final wrong = (g.round.oddIndex + 1) % g.round.tileCount;
      expect(g.tap(wrong), isFalse);
      expect(g.found, 0);
    });

    test('the grid grows from 3x3 up to 6x6', () {
      final g = OddOneOutGame(random: Random(1));
      expect(g.gridSize, 3);
      for (var i = 0; i < 3; i++) {
        g.tap(g.round.oddIndex);
      }
      expect(g.gridSize, 4);
      for (var i = 0; i < 40; i++) {
        g.tap(g.round.oddIndex);
      }
      expect(g.gridSize, 6);
      expect(g.round.oddIndex, lessThan(36));
    });
  });

  group('mandalaCellAt', () {
    const size = Size(500, 500);

    test('the middle is the centre circle', () {
      expect(mandalaCellAt(const Offset(250, 250), size), const MandalaCell(0, 0));
    });

    test('outside the circle is null', () {
      expect(mandalaCellAt(const Offset(2, 2), size), isNull);
    });

    test('moving outwards moves through the rings', () {
      // ring width = 250 / 5 = 50
      expect(mandalaCellAt(const Offset(250 + 75, 250), size)!.ring, 1);
      expect(mandalaCellAt(const Offset(250 + 125, 250), size)!.ring, 2);
      expect(mandalaCellAt(const Offset(250 + 245, 250), size)!.ring, 4);
    });

    test('going round the circle moves through the segments', () {
      // 12 segments, 30 degrees each. Straight right is angle 0 = segment 0.
      expect(mandalaCellAt(const Offset(250 + 100, 250 + 5), size)!.segment, 0);
      // Straight down is 90 degrees = segment 3.
      expect(mandalaCellAt(const Offset(250 - 5, 250 + 100), size)!.segment, 3);
      // Straight left is 180 degrees = segment 6.
      expect(mandalaCellAt(const Offset(250 - 100, 250 - 5), size)!.segment, 6);
    });
  });

  group('music tracks', () {
    test('ids are unique', () {
      final ids = musicTracks.map((t) => t.id).toSet();
      expect(ids.length, musicTracks.length);
    });

    test('every track has an audio file in assets/audio', () {
      for (final t in musicTracks) {
        expect(File(t.projectPath).existsSync(), isTrue, reason: t.projectPath);
      }
    });

    test('every category has at least two tracks', () {
      for (final c in MusicCategory.values) {
        expect(musicTracks.where((t) => t.category == c).length, greaterThanOrEqualTo(2));
      }
    });
  });
}