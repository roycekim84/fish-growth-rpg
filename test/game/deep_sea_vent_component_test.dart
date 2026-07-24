import 'dart:ui';

import 'package:fish_growth_rpg/game/components/deep_sea_vent_component.dart';
import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('damages and pushes a player inside a deep sea vent', () {
    final player = PlayerFishComponent(
      position: Vector2(10, 0),
      fieldBounds: const Rect.fromLTRB(-200, -200, 200, 200),
    );
    var damage = 0.0;
    final vent = DeepSeaVentComponent(
      position: Vector2.zero(),
      player: player,
      onDamage: (amount) => damage += amount,
      damagePerSecond: 10,
      outwardCurrentStrength: 100,
    );

    vent.update(1);

    expect(damage, closeTo(10, 0.0001));
    expect(player.movement.velocity.x, greaterThan(0));
  });

  test('does not affect a player outside the vent radius', () {
    final player = PlayerFishComponent(
      position: Vector2(150, 0),
      fieldBounds: const Rect.fromLTRB(-200, -200, 200, 200),
    );
    var damage = 0.0;
    final vent = DeepSeaVentComponent(
      position: Vector2.zero(),
      player: player,
      onDamage: (amount) => damage += amount,
    );

    vent.update(1);

    expect(damage, 0);
    expect(player.movement.velocity, Vector2.zero());
  });
}
