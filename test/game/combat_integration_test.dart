import 'package:fish_growth_rpg/game/fish_game.dart';
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

    await tester.pump(const Duration(milliseconds: 1100));

    expect(game.world.activeNpcFish, hasLength(45));
  });
}
