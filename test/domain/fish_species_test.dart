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
    });

    expect(species.id, 'small_fish');
    expect(species.maxHp, 10);
    expect(species.speed, 2.2);
    expect(species.unlockEatCount, 100);
  });
}
