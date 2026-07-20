import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a fish species definition', () {
    final species = FishSpecies.fromJson(const {
      'id': 'small_fish',
      'displayName': '작은 물고기',
      'description': '빠르지만 약함',
      'behaviorType': 'flee',
      'maxHP': 10,
      'str': 1,
      'dex': 3,
      'int': 1,
      'spd': 2.2,
      'size': 0.6,
      'weight': 0.5,
      'expReward': 5,
      'fullnessReward': 10,
      'unlockEatCount': 100,
      'maxSpawnCount': 30,
      'playerMaxHPMultiplier': 0.75,
      'playerStrengthMultiplier': 0.8,
      'playerSpeedMultiplier': 1.2,
      'playerSizeMultiplier': 0.85,
      'playerWeightMultiplier': 0.7,
      'playerTraitDescription': '빠른 종',
      'playerAbilityId': 'narrow_current',
      'playerAbilityName': '좁은 해류 통과',
      'playerAbilityDescription': '좁은 길을 통과한다.',
    });

    expect(species.id, 'small_fish');
    expect(species.maxHp, 10);
    expect(species.speed, 2.2);
    expect(species.unlockEatCount, 100);
    expect(species.playerMaxHpMultiplier, 0.75);
    expect(species.playerSpeedMultiplier, 1.2);
    expect(species.playerTraitDescription, '빠른 종');
    expect(species.playerAbilityId, 'narrow_current');
    expect(species.playerAbilityName, '좁은 해류 통과');
  });
}
