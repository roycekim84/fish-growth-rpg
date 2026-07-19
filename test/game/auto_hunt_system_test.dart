import 'dart:math';
import 'dart:ui';

import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:fish_growth_rpg/game/components/npc_fish_component.dart';
import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:fish_growth_rpg/game/systems/auto_hunt_system.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tracks edible prey and stops when danger approaches', () {
    const bounds = Rect.fromLTRB(-500, -500, 500, 500);
    final player = PlayerFishComponent(
      position: Vector2.zero(),
      fieldBounds: bounds,
    );
    final prey = _npc(
      species: _species(id: 'prey', size: 0.6),
      player: player,
      bounds: bounds,
      position: Vector2(100, 0),
    );
    final danger = _npc(
      species: _species(id: 'danger', size: 1.3),
      player: player,
      bounds: bounds,
      position: Vector2(250, 0),
    );
    final stoppedReasons = <String>[];
    final system = AutoHuntSystem(
      player: player,
      fishProvider: () => [prey, danger],
      onStopped: stoppedReasons.add,
    );

    system.setEnabled(true);
    system.update(0.2);

    expect(system.target, same(prey));
    expect(system.status.value, 'HUNT');
    expect(player.movement.isAutomaticSteering, isTrue);
    player.movement.velocity.setValues(70, 0);

    danger.position.setValues(100, 0);
    system.update(0.2);

    expect(system.enabled.value, isFalse);
    expect(system.status.value, 'DANGER');
    expect(stoppedReasons, ['DANGER']);
    expect(player.movement.isAutomaticSteering, isFalse);
    expect(player.movement.velocity, Vector2.zero());
  });

  test('does not start steering at 35 percent HP', () {
    const bounds = Rect.fromLTRB(-500, -500, 500, 500);
    final player = PlayerFishComponent(
      position: Vector2.zero(),
      fieldBounds: bounds,
    );
    player.takeDamage(26);
    final system = AutoHuntSystem(
      player: player,
      fishProvider: () => const [],
      onStopped: (_) {},
    );

    system.setEnabled(true);
    system.update(0.1);

    expect(system.enabled.value, isFalse);
    expect(system.status.value, 'LOW HP');
  });
}

NpcFishComponent _npc({
  required FishSpecies species,
  required PlayerFishComponent player,
  required Rect bounds,
  required Vector2 position,
}) {
  return NpcFishComponent(
    species: species,
    player: player,
    fieldBounds: bounds,
    position: position,
    random: Random(1),
    onRemoved: (_) {},
  );
}

FishSpecies _species({required String id, required double size}) {
  return FishSpecies(
    id: id,
    displayName: id,
    description: '',
    behaviorType: 'wander',
    maxHp: 10,
    strength: 1,
    dexterity: 1,
    intelligence: 1,
    speed: 1,
    size: size,
    weight: 1,
    expReward: 1,
    fullnessReward: 1,
    unlockEatCount: 100,
    maxSpawnCount: 1,
  );
}
