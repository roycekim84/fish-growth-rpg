import 'package:fish_growth_rpg/app/lifecycle/game_lifecycle_save_observer.dart';
import 'package:fish_growth_rpg/data/save/player_save_repository.dart';
import 'package:fish_growth_rpg/domain/models/player_save_data.dart';
import 'package:fish_growth_rpg/domain/models/quest_definition.dart';
import 'package:fish_growth_rpg/game/fish_game.dart';
import 'package:fish_growth_rpg/game/services/game_feedback_service.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('restores progress and writes a complete snapshot', (
    tester,
  ) async {
    final savedAt = DateTime.utc(2026, 7, 18, 3);
    final repository = RecordingSaveRepository(
      SaveLoadResult(
        state: SaveLoadState.loaded,
        data: PlayerSaveData(
          level: 3,
          exp: 12,
          fullness: 64,
          hp: 20,
          currentSpeciesId: 'puffer_fish',
          unlockedSpeciesIds: {'starter_fish', 'puffer_fish'},
          discoveredSpeciesIds: {'small_fish', 'puffer_fish'},
          discoveredRegionIds: {'ocean_shallows'},
          discoveredPointIdsByRegionId: {
            'ocean_shallows': {'sunlit_kelp'},
          },
          questStatusById: {'shallow_trail': QuestStatus.active},
          eatenCountBySpeciesId: {'small_fish': 100, 'puffer_fish': 37},
          lastSaveTimeUtc: savedAt,
        ),
      ),
    );
    final now = DateTime.utc(2026, 7, 19, 8, 45);
    final game = FishGame(
      saveRepository: repository,
      now: () => now,
      feedbackService: const SilentGameFeedbackService(),
    );

    await tester.pumpWidget(
      MaterialApp(home: GameWidget<FishGame>(game: game)),
    );
    for (
      var i = 0;
      i < 120 && game.saveStatus.value == SaveStatus.loading;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(game.saveStatus.value, SaveStatus.loaded);
    expect(game.world.player.progress.level, 3);
    expect(game.world.player.progress.exp, 12);
    expect(game.world.player.progress.fullness, 64);
    expect(game.world.player.progress.currentSpeciesId, 'puffer_fish');
    expect(game.world.player.currentSpeciesName, '복어');
    expect(game.world.player.maxHp, closeTo(67.5, 0.0001));
    expect(game.world.player.hp.value, 20);
    expect(game.world.currentRegion!.id, 'ocean_shallows');
    expect(
      game.world.player.progress.discoveredPointIdsForRegion('ocean_shallows'),
      {'sunlit_kelp'},
    );
    expect(
      game.world.player.progress.questStatus('shallow_trail'),
      QuestStatus.active,
    );

    await game.saveNow();

    expect(repository.saved, hasLength(1));
    expect(repository.saved.single.level, 3);
    expect(repository.saved.single.hp, 20);
    expect(repository.saved.single.currentSpeciesId, 'puffer_fish');
    expect(repository.saved.single.lastSaveTimeUtc, now);
    expect(game.saveStatus.value, SaveStatus.saved);

    final observer = GameLifecycleSaveObserver(game: game);
    await observer.saveForState(AppLifecycleState.paused);
    expect(repository.saved, hasLength(2));
    expect(repository.saved.last.schemaVersion, 3);
    expect(repository.saved.last.lastSaveTimeUtc.isUtc, isTrue);

    await observer.saveForState(AppLifecycleState.resumed);
    expect(repository.saved, hasLength(2));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

class RecordingSaveRepository implements PlayerSaveRepository {
  RecordingSaveRepository(this.loadResult);

  final SaveLoadResult loadResult;
  final List<PlayerSaveData> saved = [];

  @override
  Future<SaveLoadResult> load() async => loadResult;

  @override
  Future<void> save(PlayerSaveData data) async {
    saved.add(data);
  }
}
