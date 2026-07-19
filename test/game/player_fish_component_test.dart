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

  test('takes damage and fully recovers when revived', () {
    const bounds = Rect.fromLTRB(-100, -100, 100, 100);
    final player = PlayerFishComponent(
      position: Vector2(25, 30),
      fieldBounds: bounds,
    );
    player.movement.velocity.setValues(20, 10);

    expect(player.takeDamage(12), isFalse);
    expect(player.hp.value, 28);
    expect(player.takeDamage(50), isTrue);
    expect(player.hp.value, 0);

    player.reviveAt(Vector2.zero());

    expect(player.hp.value, player.maxHp);
    expect(player.position, Vector2.zero());
    expect(player.movement.velocity, Vector2.zero());
  });
}
