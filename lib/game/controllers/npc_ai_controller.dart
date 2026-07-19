import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

enum NpcAiState { wander, flee, chase }

class NpcAiController {
  NpcAiController({
    required this.behaviorType,
    required this.npcSize,
    math.Random? random,
    this.detectionRange = 220,
    this.boundaryMargin = 72,
  }) : _random = random ?? math.Random();

  final String behaviorType;
  final double npcSize;
  final double detectionRange;
  final double boundaryMargin;
  final math.Random _random;

  final Vector2 desiredDirection = Vector2(1, 0);
  NpcAiState state = NpcAiState.wander;

  double _decisionCooldown = 0;
  double _wanderCooldown = 0;

  void update({
    required double deltaTime,
    required Vector2 position,
    required Vector2 playerPosition,
    required double playerSize,
    required Rect fieldBounds,
  }) {
    final distanceToPlayer = position.distanceTo(playerPosition);
    _decisionCooldown -= deltaTime;
    _wanderCooldown -= deltaTime;

    if (_decisionCooldown <= 0) {
      _selectState(distanceToPlayer: distanceToPlayer, playerSize: playerSize);
      _decisionCooldown = distanceToPlayer > detectionRange * 2.5 ? 0.6 : 0.15;
    }

    final centerSteering = _boundarySteering(position, fieldBounds);
    if (centerSteering != null) {
      desiredDirection.setFrom(centerSteering);
      return;
    }

    switch (state) {
      case NpcAiState.flee:
        _setDirection(position - playerPosition);
      case NpcAiState.chase:
        _setDirection(playerPosition - position);
      case NpcAiState.wander:
        if (_wanderCooldown <= 0) {
          final angle = _random.nextDouble() * math.pi * 2;
          desiredDirection.setValues(math.cos(angle), math.sin(angle));
          _wanderCooldown = 1.2 + _random.nextDouble() * 1.6;
        }
    }
  }

  void _selectState({
    required double distanceToPlayer,
    required double playerSize,
  }) {
    if (distanceToPlayer > detectionRange) {
      state = NpcAiState.wander;
      return;
    }

    if (playerSize >= npcSize * 1.15) {
      state = NpcAiState.flee;
      return;
    }

    final chaseRatio = switch (behaviorType) {
      'hunter' => 0.9,
      'defensive' => 0.7,
      _ => 0.72,
    };
    state = playerSize < npcSize * chaseRatio
        ? NpcAiState.chase
        : NpcAiState.wander;
  }

  Vector2? _boundarySteering(Vector2 position, Rect bounds) {
    var x = 0.0;
    var y = 0.0;
    if (position.x < bounds.left + boundaryMargin) {
      x = 1;
    } else if (position.x > bounds.right - boundaryMargin) {
      x = -1;
    }
    if (position.y < bounds.top + boundaryMargin) {
      y = 1;
    } else if (position.y > bounds.bottom - boundaryMargin) {
      y = -1;
    }
    if (x == 0 && y == 0) {
      return null;
    }
    return Vector2(x, y).normalized();
  }

  void _setDirection(Vector2 direction) {
    if (direction.length2 > 0.001) {
      desiredDirection.setFrom(direction.normalized());
    }
  }
}
