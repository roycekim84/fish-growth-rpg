import 'dart:ui';

import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:fish_growth_rpg/domain/models/player_progress.dart';
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

  test('applies species multipliers while preserving the HP ratio', () {
    const bounds = Rect.fromLTRB(-100, -100, 100, 100);
    final progress = PlayerProgress(unlockedSpeciesIds: {'puffer_fish'});
    final player = PlayerFishComponent(
      position: Vector2.zero(),
      fieldBounds: bounds,
      progress: progress,
    );
    player.takeDamage(20);
    final oldRatio = player.hp.value / player.maxHp;

    expect(player.equipSpecies(_pufferSpecies()), isTrue);

    expect(player.maxHp, 54);
    expect(player.hp.value / player.maxHp, closeTo(oldRatio, 0.0001));
    expect(player.gameplaySize, closeTo(0.92, 0.0001));
    expect(player.weight, closeTo(1.4, 0.0001));
    expect(player.movement.currentMaxSpeed, closeTo(105.3, 0.001));
    expect(progress.currentSpeciesId, 'puffer_fish');
  });

  test('does not equip a locked species', () {
    const bounds = Rect.fromLTRB(-100, -100, 100, 100);
    final player = PlayerFishComponent(
      position: Vector2.zero(),
      fieldBounds: bounds,
    );

    expect(player.equipSpecies(_pufferSpecies()), isFalse);
    expect(player.currentSpecies, isNull);
  });
}

FishSpecies _pufferSpecies() {
  return const FishSpecies(
    id: 'puffer_fish',
    displayName: '복어',
    description: '방어형',
    behaviorType: 'defensive',
    maxHp: 35,
    strength: 4,
    dexterity: 1,
    intelligence: 2,
    speed: 1.1,
    size: 1,
    weight: 1.5,
    expReward: 20,
    fullnessReward: 25,
    unlockEatCount: 100,
    maxSpawnCount: 10,
    playerMaxHpMultiplier: 1.35,
    playerStrengthMultiplier: 1,
    playerSpeedMultiplier: 0.78,
    playerSizeMultiplier: 1.15,
    playerWeightMultiplier: 1.4,
  );
}
