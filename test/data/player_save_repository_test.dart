import 'dart:convert';

import 'package:fish_growth_rpg/data/save/player_save_repository.dart';
import 'package:fish_growth_rpg/domain/models/player_save_data.dart';
import 'package:fish_growth_rpg/domain/models/player_progress.dart';
import 'package:fish_growth_rpg/domain/models/quest_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JsonPlayerSaveRepository', () {
    test('round-trips schema v3 progress and UTC save time', () async {
      final store = MemoryStringPreferencesStore();
      final repository = JsonPlayerSaveRepository(store);
      final progress = PlayerProgress(
        level: 4,
        exp: 17,
        fullness: 72,
        currentSpeciesId: 'puffer_fish',
        eatenCountBySpeciesId: {'small_fish': 100, 'puffer_fish': 41},
        unlockedSpeciesIds: {'small_fish', 'puffer_fish'},
        discoveredSpeciesIds: {'small_fish', 'puffer_fish'},
        discoveredRegionIds: {'ocean_shallows'},
        discoveredPointIdsByRegionId: {
          'ocean_shallows': {'sunlit_kelp', 'blue_current'},
        },
        questStatusById: {'shallow_trail': QuestStatus.active},
      );
      final savedAt = DateTime.parse('2026-07-19T17:30:00+09:00');

      await repository.save(
        PlayerSaveData.capture(progress: progress, hp: 31.5, savedAt: savedAt),
      );
      final result = await repository.load();

      expect(result.state, SaveLoadState.loaded);
      expect(result.data!.schemaVersion, 3);
      expect(result.data!.level, 4);
      expect(result.data!.exp, 17);
      expect(result.data!.hp, 31.5);
      expect(result.data!.currentSpeciesId, 'puffer_fish');
      expect(result.data!.eatenCountBySpeciesId['small_fish'], 100);
      expect(result.data!.discoveredRegionIds, {'ocean_shallows'});
      expect(result.data!.discoveredPointIdsByRegionId['ocean_shallows'], {
        'sunlit_kelp',
        'blue_current',
      });
      expect(result.data!.questStatusById['shallow_trail'], QuestStatus.active);
      expect(result.data!.lastSaveTimeUtc.isUtc, isTrue);
      expect(result.data!.lastSaveTimeUtc, DateTime.utc(2026, 7, 19, 8, 30));
    });

    test('migrates schema v1 saves without region progress', () {
      final data = PlayerSaveData.fromJson({
        'schemaVersion': 1,
        'level': 1,
        'exp': 0,
        'fullness': 50,
        'hp': 40,
        'currentSpeciesId': PlayerProgress.starterSpeciesId,
        'unlockedSpeciesIds': [PlayerProgress.starterSpeciesId],
        'discoveredSpeciesIds': <String>[],
        'eatenCountBySpeciesId': <String, int>{},
        'lastSaveTimeUtc': '2026-07-19T00:00:00Z',
      });

      expect(data.schemaVersion, 3);
      expect(data.discoveredRegionIds, isEmpty);
      expect(data.discoveredPointIdsByRegionId, isEmpty);
    });

    test('removes corrupt data and starts from a safe empty state', () async {
      final store = MemoryStringPreferencesStore()
        ..values[JsonPlayerSaveRepository.saveKey] = '{broken json';
      final repository = JsonPlayerSaveRepository(store);

      final result = await repository.load();

      expect(result.state, SaveLoadState.recoveredCorrupt);
      expect(result.data, isNull);
      expect(store.values, isNot(contains(JsonPlayerSaveRepository.saveKey)));
    });

    test('preserves a future schema instead of overwriting it', () async {
      final store = MemoryStringPreferencesStore()
        ..values[JsonPlayerSaveRepository.saveKey] = jsonEncode({
          'schemaVersion': 99,
        });
      final repository = JsonPlayerSaveRepository(store);

      final result = await repository.load();

      expect(result.state, SaveLoadState.unsupportedVersion);
      expect(result.data, isNull);
      expect(store.values, contains(JsonPlayerSaveRepository.saveKey));
    });

    test('rejects invalid negative progress values', () {
      expect(
        () => PlayerSaveData.fromJson({
          'schemaVersion': 1,
          'level': -1,
          'exp': 0,
          'fullness': 50,
          'hp': 40,
          'currentSpeciesId': PlayerProgress.starterSpeciesId,
          'unlockedSpeciesIds': [PlayerProgress.starterSpeciesId],
          'discoveredSpeciesIds': <String>[],
          'eatenCountBySpeciesId': <String, int>{},
          'lastSaveTimeUtc': '2026-07-19T00:00:00Z',
        }),
        throwsFormatException,
      );
    });
  });
}

class MemoryStringPreferencesStore implements StringPreferencesStore {
  final Map<String, String> values = {};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }
}
