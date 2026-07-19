import 'dart:ui';

import 'package:fish_growth_rpg/data/species/species_repository.dart';
import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:fish_growth_rpg/game/components/drag_input_surface.dart';
import 'package:fish_growth_rpg/game/components/underwater_light_overlay.dart';
import 'package:fish_growth_rpg/game/fish_world.dart';
import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

class FishGame extends FlameGame<FishWorld> {
  factory FishGame() {
    final fishWorld = FishWorld();
    final camera = CameraComponent.withFixedResolution(
      world: fishWorld,
      width: logicalWidth,
      height: logicalHeight,
    );
    return FishGame._(world: fishWorld, camera: camera);
  }

  FishGame._({required FishWorld world, required CameraComponent camera})
    : super(world: world, camera: camera);

  static const double logicalWidth = 360;
  static const double logicalHeight = 640;

  final ValueNotifier<int> loadedSpeciesCount = ValueNotifier<int>(0);
  final ValueNotifier<bool> boostState = ValueNotifier<bool>(false);
  List<FishSpecies> species = const [];

  @override
  Color backgroundColor() => const Color(0xFF071A2D);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    species = await SpeciesRepository().loadAll();
    loadedSpeciesCount.value = species.length;
    await world.initializeSpecies(species);
    world.playerDefeatCount.addListener(_handlePlayerDefeat);
    await camera.viewport.addAll([
      UnderwaterLightOverlay(logicalSize: Vector2(logicalWidth, logicalHeight)),
      DragInputSurface(
        movement: world.player.movement,
        logicalSize: Vector2(logicalWidth, logicalHeight),
      ),
    ]);
    camera.follow(world.player, maxSpeed: 420, snap: true);
  }

  void setBoosting(bool value) {
    if (boostState.value == value) {
      return;
    }
    world.player.movement.setBoosting(value);
    boostState.value = value;
  }

  void _handlePlayerDefeat() {
    setBoosting(false);
  }

  @override
  void onRemove() {
    world.playerDefeatCount.removeListener(_handlePlayerDefeat);
    loadedSpeciesCount.dispose();
    boostState.dispose();
    super.onRemove();
  }
}
