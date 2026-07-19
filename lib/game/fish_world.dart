import 'dart:ui';

import 'package:fish_growth_rpg/game/components/field_boundary_component.dart';
import 'package:fish_growth_rpg/game/components/ocean_backdrop.dart';
import 'package:fish_growth_rpg/game/components/npc_fish_component.dart';
import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:fish_growth_rpg/game/systems/auto_hunt_system.dart';
import 'package:fish_growth_rpg/game/systems/combat_system.dart';
import 'package:fish_growth_rpg/game/systems/npc_spawn_system.dart';
import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

class FishWorld extends World with HasCollisionDetection {
  FishWorld()
    : player = PlayerFishComponent(
        position: Vector2.zero(),
        fieldBounds: fieldBounds,
      ) {
    combatSystem = CombatSystem(
      player: player,
      onFishConsumed: (_) => consumedFishCount.value++,
      onPlayerDefeated: () => playerDefeatCount.value++,
      onCombatMessage: setCombatMessage,
    );
    autoHuntSystem = AutoHuntSystem(
      player: player,
      fishProvider: () => activeNpcFish,
      onStopped: (reason) => setCombatMessage('AUTO $reason'),
    );
  }

  static const Rect fieldBounds = Rect.fromLTRB(-640, -850, 640, 850);

  final PlayerFishComponent player;
  final ValueNotifier<int> npcCount = ValueNotifier<int>(0);
  final ValueNotifier<int> consumedFishCount = ValueNotifier<int>(0);
  final ValueNotifier<int> playerDefeatCount = ValueNotifier<int>(0);
  final ValueNotifier<String> combatMessage = ValueNotifier<String>('');
  late final CombatSystem combatSystem;
  late final AutoHuntSystem autoHuntSystem;

  NpcSpawnSystem? _spawnSystem;
  double _combatMessageRemaining = 0;

  List<NpcFishComponent> get activeNpcFish =>
      _spawnSystem?.activeFish ?? const [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await addAll([
      OceanBackdrop(),
      FieldBoundaryComponent(bounds: fieldBounds),
      combatSystem,
      autoHuntSystem,
      player,
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_combatMessageRemaining <= 0) {
      return;
    }
    _combatMessageRemaining -= dt;
    if (_combatMessageRemaining <= 0) {
      combatMessage.value = '';
    }
  }

  void setCombatMessage(String message) {
    combatMessage.value = message;
    _combatMessageRemaining = 0.9;
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
    consumedFishCount.dispose();
    playerDefeatCount.dispose();
    combatMessage.dispose();
    super.onRemove();
  }
}
