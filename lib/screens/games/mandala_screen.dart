import 'dart:math';

import 'package:flutter/material.dart';

import '../../games/mandala_logic.dart';
import '../../widgets/zone_widgets.dart';

const _palette = <Color>[
  Color(0xFF4DB6AC), Color(0xFF64B5F6), Color(0xFF9575CD), Color(0xFFF06292),
  Color(0xFFFFB74D), Color(0xFFAED581), Color(0xFFFFF176),
];

/// Stress relief: colour in the mandala, one piece at a time.
class MandalaScreen extends StatefulWidget {
  const MandalaScreen({super.key});

  @override
  State<MandalaScreen> createState() => _MandalaScreenState();
}

class _MandalaScreenState extends State<MandalaScreen> {
  static const int _rings = 4;
  static const int _segments = 12;

  final Map<MandalaCell, Color> _fills = {};
  Color _selected = _palette.first;

  void _paintAt(Offset point, Size size) {
    final cell = mandalaCellAt(point, size, rings: _rings, segments: _segments);
    if (cell == null) return;
    setState(() {
      if (_fills[cell] == _selected) {
        _fills.remove(cell); // tap again with the same colour to clear it
      } else {
        _fills[cell] = _selected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameFrame(
      title: 'Colour Mandala',
      children: [
        const Text('Pick a colour, then tap the shapes to fill them in.'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final c in _palette)
              GestureDetector(
                onTap: () => setState(() => _selected = c),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: c == _selected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) {
            final side = c.maxWidth;
            final size = Size(side, side);
            return GestureDetector(
              onTapDown: (d) => _paintAt(d.localPosition, size),
              child: CustomPaint(
                size: size,
                painter: _MandalaPainter(_fills, _rings, _segments),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => setState(_fills.clear),
          child: const Text('Clear'),
        ),
      ],
    );
  }
}

class _MandalaPainter extends CustomPainter {
  final Map<MandalaCell, Color> fills;
  final int rings;
  final int segments;
  _MandalaPainter(this.fills, this.rings, this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2;
    final ringWidth = radius / (rings + 1);
    final sweep = 2 * pi / segments;

    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF9DB7BF);

    fill.color = fills[const MandalaCell(0, 0)] ?? Colors.white;
    canvas.drawCircle(centre, ringWidth, fill);
    canvas.drawCircle(centre, ringWidth, line);

    for (var ring = 1; ring <= rings; ring++) {
      final inner = Rect.fromCircle(center: centre, radius: ring * ringWidth);
      final outer = Rect.fromCircle(center: centre, radius: (ring + 1) * ringWidth);
      for (var seg = 0; seg < segments; seg++) {
        final start = seg * sweep;
        final path = Path()
          ..arcTo(outer, start, sweep, true)
          ..arcTo(inner, start + sweep, -sweep, false)
          ..close();
        fill.color = fills[MandalaCell(ring, seg)] ?? Colors.white;
        canvas.drawPath(path, fill);
        canvas.drawPath(path, line);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MandalaPainter old) => true;
}