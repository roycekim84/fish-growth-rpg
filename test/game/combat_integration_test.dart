import 'package:fish_growth_rpg/game/fish_game.dart';
import 'package:fish_growth_rpg/game/fish_world.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('consumes a smaller fish on contact and respawns it', (
    tester,
  ) async {
    final game = FishGame();
    await tester.pumpWidget(
      MaterialApp(home: GameWidget<FishGame>(game: game)),
    );

    for (var i = 0; i < 120 && game.world.activeNpcFish.length < 45; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(game.world.activeNpcFish, hasLength(45));
    final prey = game.world.activeNpcFish.firstWhere(
      (fish) => fish.species.id == 'small_fish',
    );
    prey.position.setFrom(game.world.player.position);
    prey.velocity.setZero();

    for (var i = 0; i < 5 && game.world.consumedFishCount.value == 0; i++) {
      prey.position.setFrom(game.world.player.position);
      prey.velocity.setZero();
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(game.world.consumedFishCount.value, 1);
    expect(game.world.player.progress.exp, 5);
    expect(game.world.player.progress.fullness, 60);
    expect(game.world.player.progress.eatenCountBySpeciesId['small_fish'], 1);

    await tester.pump(const Duration(milliseconds: 1100));

    expect(game.world.activeNpcFish, hasLength(45));

    game.world.player.progress.unlockedSpeciesIds.add('puffer_fish');
    game.world.player.progress.unlockedSpeciesIds.add('hunter_fish');
    game.world.player.takeDamage(10);
    final hpRatioBefore = game.world.player.hp.value / game.world.player.maxHp;

    expect(
      game.world.changeSpecies('puffer_fish'),
      SpeciesChangeResult.success,
    );
    expect(game.world.player.progress.currentSpeciesId, 'puffer_fish');
    expect(
      game.world.player.hp.value / game.world.player.maxHp,
      closeTo(hpRatioBefore, 0.0001),
    );

    game.world.recoverySystem.markCombat();
    expect(
      game.world.changeSpecies('hunter_fish'),
      SpeciesChangeResult.inCombat,
    );
    expect(game.world.player.progress.currentSpeciesId, 'puffer_fish');
  });
}
