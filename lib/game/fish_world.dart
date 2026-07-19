import 'dart:ui';

import 'package:fish_growth_rpg/game/components/field_boundary_component.dart';
import 'package:fish_growth_rpg/game/components/ocean_backdrop.dart';
import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:fish_growth_rpg/game/systems/npc_spawn_system.dart';
import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

class FishWorld extends World {
  FishWorld()
    : player = PlayerFishComponent(
        position: Vector2.zero(),
        fieldBounds: fieldBounds,
      );

  static const Rect fieldBounds = Rect.fromLTRB(-640, -850, 640, 850);

  final PlayerFishComponent player;
  final ValueNotifier<int> npcCount = ValueNotifier<int>(0);

  NpcSpawnSystem? _spawnSystem;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await addAll([
      OceanBackdrop(),
      FieldBoundaryComponent(bounds: fieldBounds),
      player,
    ]);
  }

  Future<void> initializeSpecies(List<FishSpecies> species) async {
    if (_spawnSystem != null) {
      return;
    }
    final system = NpcSpawnSystem(fishWorld: this, species: species);
    _spawnSystem = system;
    await add(system);
  }

  @override
  void onRemove() {
    npcCount.dispose();
    super.onRemove();
  }
}
