import 'dart:math' as math;
import 'dart:ui';

import 'package:fish_growth_rpg/game/systems/spawn_position_picker.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('picks positions inside the field and away from the player', () {
    const bounds = Rect.fromLTRB(-640, -850, 640, 850);
    final picker = SpawnPositionPicker(
      fieldBounds: bounds,
      minimumPlayerDistance: 280,
      edgePadding: 48,
      random: math.Random(7),
    );
    final playerPosition = Vector2.zero();

    for (var i = 0; i < 30; i++) {
      final position = picker.pick(playerPosition: playerPosition);

      expect(position, isNotNull);
      expect(
        position!.x,
        inInclusiveRange(bounds.left + 48, bounds.right - 48),
      );
      expect(position.y, inInclusiveRange(bounds.top + 48, bounds.bottom - 48));
      expect(position.distanceTo(playerPosition), greaterThanOrEqualTo(280));
    }
  });

  test('avoids occupied NPC positions', () {
    const bounds = Rect.fromLTRB(-200, -200, 200, 200);
    final picker = SpawnPositionPicker(
      fieldBounds: bounds,
      minimumPlayerDistance: 50,
      edgePadding: 20,
      random: math.Random(11),
    );
    final occupied = [Vector2(100, 100), Vector2(-100, -100)];

    final position = picker.pick(
      playerPosition: Vector2.zero(),
      occupiedPositions: occupied,
      minimumNpcDistance: 60,
    );

    expect(position, isNotNull);
    for (final other in occupied) {
      expect(position!.distanceTo(other), greaterThanOrEqualTo(60));
    }
  });
}
