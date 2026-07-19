import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

class SpawnPositionPicker {
  SpawnPositionPicker({
    required this.fieldBounds,
    required this.minimumPlayerDistance,
    required this.edgePadding,
    math.Random? random,
  }) : _random = random ?? math.Random();

  final Rect fieldBounds;
  final double minimumPlayerDistance;
  final double edgePadding;
  final math.Random _random;

  Vector2? pick({
    required Vector2 playerPosition,
    Iterable<Vector2> occupiedPositions = const [],
    double minimumNpcDistance = 28,
    int maxAttempts = 32,
  }) {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final candidate = Vector2(
        _between(
          fieldBounds.left + edgePadding,
          fieldBounds.right - edgePadding,
        ),
        _between(
          fieldBounds.top + edgePadding,
          fieldBounds.bottom - edgePadding,
        ),
      );
      if (candidate.distanceTo(playerPosition) < minimumPlayerDistance) {
        continue;
      }
      final overlapsNpc = occupiedPositions.any(
        (position) => candidate.distanceTo(position) < minimumNpcDistance,
      );
      if (!overlapsNpc) {
        return candidate;
      }
    }
    return null;
  }

  double _between(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }
}
