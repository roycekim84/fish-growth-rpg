import 'dart:ui';

import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:fish_growth_rpg/domain/models/player_progress.dart';
import 'package:fish_growth_rpg/game/components/ability_gate_component.dart';
import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bounds = Rect.fromLTRB(-100, -100, 100, 100);

  test('blocks a player without the gate ability', () {
    final player = PlayerFishComponent(
      position: Vector2(5, 5),
      fieldBounds: bounds,
    );
    final gate = AbilityGateComponent(
      bounds: const Rect.fromLTWH(0, 0, 40, 40),
      player: player,
      requiredAbilityId: 'narrow_current',
      label: 'NARROW CURRENT',
      onBlocked: (_) {},
    );

    gate.update(0.1);

    expect(player.position.x, lessThan(0));
  });

  test('allows a player with the matching ability through', () {
    final progress = PlayerProgress(unlockedSpeciesIds: {'small_fish'});
    final player = PlayerFishComponent(
      position: Vector2(5, 5),
      fieldBounds: bounds,
      progress: progress,
    );
    player.equipSpecies(_smallFish());
    final gate = AbilityGateComponent(
      bounds: const Rect.fromLTWH(0, 0, 40, 40),
      player: player,
      requiredAbilityId: 'narrow_current',
      label: 'NARROW CURRENT',
      onBlocked: (_) {},
    );

    gate.update(0.1);

    expect(player.position, Vector2(5, 5));
  });
}

FishSpecies _smallFish() {
  return const FishSpecies(
    id: 'small_fish',
    displayName: '작은 물고기',
    description: '빠름',
    behaviorType: 'flee',
    maxHp: 10,
    strength: 1,
    dexterity: 3,
    intelligence: 1,
    speed: 2.2,
    size: 0.6,
    weight: 0.5,
    expReward: 5,
    fullnessReward: 10,
    unlockEatCount: 100,
    maxSpawnCount: 30,
    playerAbilityId: 'narrow_current',
    playerAbilityName: '좁은 해류 통과',
    playerAbilityDescription: '통과',
  );
}
