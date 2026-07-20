import 'package:fish_growth_rpg/domain/models/player_progress.dart';
import 'package:fish_growth_rpg/domain/models/quest_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerProgress', () {
    test('applies multiple level-ups and preserves remaining EXP', () {
      final progress = PlayerProgress(fullness: 0);

      final result = progress.recordConsumption(
        speciesId: 'hunter_fish',
        expReward: 100,
        fullnessReward: 35,
      );

      expect(result.levelsGained, 2);
      expect(progress.level, 3);
      expect(progress.exp, 30);
      expect(progress.requiredExp, 50);
      expect(progress.maxHp, 50);
      expect(progress.strength, 5);
      expect(progress.size, closeTo(0.86, 0.0001));
      expect(progress.weight, closeTo(1.1, 0.0001));
    });

    test('caps fullness and counts each consumed species', () {
      final progress = PlayerProgress(fullness: 95);

      final first = progress.recordConsumption(
        speciesId: 'small_fish',
        expReward: 5,
        fullnessReward: 10,
      );
      final second = progress.recordConsumption(
        speciesId: 'small_fish',
        expReward: 5,
        fullnessReward: 10,
      );

      expect(progress.fullness, PlayerProgress.maxFullness);
      expect(first.fullnessGained, 5);
      expect(second.fullnessGained, 0);
      expect(first.speciesEatCount, 1);
      expect(second.speciesEatCount, 2);
      expect(progress.totalEaten, 2);
    });

    test('never consumes more fullness than remains', () {
      final progress = PlayerProgress(fullness: 2);

      expect(progress.consumeFullness(5), 2);
      expect(progress.fullness, 0);
    });

    test('unlocks a species once at the 100th consumption', () {
      final progress = PlayerProgress(
        eatenCountBySpeciesId: {'puffer_fish': 99},
      );

      final unlocked = progress.recordConsumption(
        speciesId: 'puffer_fish',
        expReward: 0,
        fullnessReward: 0,
        unlockEatCount: 100,
      );
      final repeated = progress.recordConsumption(
        speciesId: 'puffer_fish',
        expReward: 0,
        fullnessReward: 0,
        unlockEatCount: 100,
      );

      expect(unlocked.speciesEatCount, 100);
      expect(unlocked.newlyUnlockedSpeciesId, 'puffer_fish');
      expect(progress.isSpeciesUnlocked('puffer_fish'), isTrue);
      expect(repeated.newlyUnlockedSpeciesId, isNull);
    });

    test('rejects changing to a locked species', () {
      final progress = PlayerProgress();

      expect(progress.changeSpecies('hunter_fish'), isFalse);
      expect(progress.currentSpeciesId, PlayerProgress.starterSpeciesId);
    });

    test('records a region and each discovered landmark once', () {
      final progress = PlayerProgress();

      expect(progress.discoverRegion('ocean_shallows'), isTrue);
      expect(progress.discoverRegion('ocean_shallows'), isFalse);
      expect(progress.discoverPoint('ocean_shallows', 'sunlit_kelp'), isTrue);
      expect(progress.discoverPoint('ocean_shallows', 'sunlit_kelp'), isFalse);
      expect(progress.discoveredPointIdsForRegion('ocean_shallows'), {
        'sunlit_kelp',
      });
    });

    test('moves quests through inactive, active, and completed states', () {
      final progress = PlayerProgress();

      expect(progress.questStatus('shallow_trail'), QuestStatus.inactive);
      expect(progress.startQuest('shallow_trail'), isTrue);
      expect(progress.startQuest('shallow_trail'), isFalse);
      expect(progress.completeQuest('shallow_trail'), isTrue);
      expect(progress.completeQuest('shallow_trail'), isFalse);
      expect(progress.unlockSpeciesFromQuest('small_fish'), isTrue);
      expect(progress.isSpeciesUnlocked('small_fish'), isTrue);
    });
  });
}
