import 'dart:ui';

import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps the player inside the field and stops outward velocity', () {
    const bounds = Rect.fromLTRB(-100, -100, 100, 100);
    final player = PlayerFishComponent(
      position: Vector2(200, 200),
      fieldBounds: bounds,
    );
    player.movement.velocity.setValues(50, 50);

    player.update(1 / 60);

    expect(player.position.x, bounds.right - player.size.x / 2);
    expect(player.position.y, bounds.bottom - player.size.y / 2);
    expect(player.movement.velocity, Vector2.zero());
  });
}
