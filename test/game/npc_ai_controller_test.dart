import 'dart:math' as math;
import 'dart:ui';

import 'package:fish_growth_rpg/game/controllers/npc_ai_controller.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bounds = Rect.fromLTRB(-640, -850, 640, 850);

  group('NpcAiController', () {
    test('small fish flees from a player large enough to eat it', () {
      final ai = NpcAiController(
        behaviorType: 'flee',
        npcSize: 0.6,
        random: math.Random(1),
      );

      ai.update(
        deltaTime: 0.16,
        position: Vector2.zero(),
        playerPosition: Vector2(100, 0),
        playerSize: 0.8,
        fieldBounds: bounds,
      );

      expect(ai.state, NpcAiState.flee);
      expect(ai.desiredDirection.x, lessThan(0));
    });

    test('hunter fish chases a smaller player', () {
      final ai = NpcAiController(
        behaviorType: 'hunter',
        npcSize: 1.3,
        random: math.Random(2),
      );

      ai.update(
        deltaTime: 0.16,
        position: Vector2.zero(),
        playerPosition: Vector2(100, 0),
        playerSize: 0.8,
        fieldBounds: bounds,
      );

      expect(ai.state, NpcAiState.chase);
      expect(ai.desiredDirection.x, greaterThan(0));
    });

    test('puffer fish stays defensive against a similarly sized player', () {
      final ai = NpcAiController(
        behaviorType: 'defensive',
        npcSize: 1,
        random: math.Random(3),
      );

      ai.update(
        deltaTime: 0.16,
        position: Vector2.zero(),
        playerPosition: Vector2(100, 0),
        playerSize: 0.8,
        fieldBounds: bounds,
      );

      expect(ai.state, NpcAiState.wander);
    });

    test('returns to wandering outside detection range', () {
      final ai = NpcAiController(
        behaviorType: 'hunter',
        npcSize: 1.3,
        random: math.Random(4),
      );

      ai.update(
        deltaTime: 0.16,
        position: Vector2.zero(),
        playerPosition: Vector2(400, 0),
        playerSize: 0.5,
        fieldBounds: bounds,
      );

      expect(ai.state, NpcAiState.wander);
    });

    test('steers back toward the field near a boundary', () {
      final ai = NpcAiController(
        behaviorType: 'flee',
        npcSize: 0.6,
        random: math.Random(5),
      );

      ai.update(
        deltaTime: 0.16,
        position: Vector2(bounds.left + 10, 0),
        playerPosition: Vector2.zero(),
        playerSize: 0.8,
        fieldBounds: bounds,
      );

      expect(ai.desiredDirection.x, greaterThan(0));
    });
  });
}
