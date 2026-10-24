import 'dart:math';
import 'dart:ui';

class MandalaCell {
  final int ring; // 0 is the centre circle
  final int segment;
  const MandalaCell(this.ring, this.segment);

  @override
  bool operator ==(Object other) =>
      other is MandalaCell && other.ring == ring && other.segment == segment;

  @override
  int get hashCode => Object.hash(ring, segment);
}

/// Which part of the mandala is under [point], or null if it is outside.
MandalaCell? mandalaCellAt(
  Offset point,
  Size size, {
  int rings = 4,
  int segments = 12,
}) {
  final centre = size.center(Offset.zero);
  final radius = min(size.width, size.height) / 2;
  final d = point - centre;
  final r = d.distance;
  if (r > radius) return null;

  final ringWidth = radius / (rings + 1);
  final ring = min(rings, (r / ringWidth).floor());
  if (ring == 0) return const MandalaCell(0, 0);

  var angle = atan2(d.dy, d.dx);
  if (angle < 0) angle += 2 * pi;
  final segment = min(segments - 1, (angle / (2 * pi / segments)).floor());
  return MandalaCell(ring, segment);
}