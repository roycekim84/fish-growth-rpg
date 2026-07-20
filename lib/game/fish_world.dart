import 'dart:ui';

import 'package:fish_growth_rpg/domain/models/player_save_data.dart';
import 'package:fish_growth_rpg/domain/models/player_progress.dart';
import 'package:fish_growth_rpg/domain/models/region_definition.dart';
import 'package:fish_growth_rpg/game/components/field_boundary_component.dart';
import 'package:fish_growth_rpg/game/components/impact_burst_component.dart';
import 'package:fish_growth_rpg/game/components/ocean_backdrop.dart';
import 'package:fish_growth_rpg/game/components/npc_fish_component.dart';
import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:fish_growth_rpg/game/systems/auto_hunt_system.dart';
import 'package:fish_growth_rpg/game/systems/combat_system.dart';
import 'package:fish_growth_rpg/game/systems/npc_spawn_system.dart';
import 'package:fish_growth_rpg/game/systems/recovery_system.dart';
import 'package:fish_growth_rpg/game/systems/region_discovery_system.dart';
import 'package:fish_growth_rpg/game/services/game_feedback_service.dart';
import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

class FishWorld extends World with HasCollisionDetection {
  FishWorld({required this.onFeedback})
    : player = PlayerFishComponent(
        position: Vector2.zero(),
        fieldBounds: fieldBounds,
      ) {
    recoverySystem = RecoverySystem(
      player: player,
      onRecoveryStarted: () => setCombatMessage('RECOVERING'),
    );
    combatSystem = CombatSystem(
      player: player,
      onFishConsumed: _handleFishConsumed,
      onPlayerDefeated: () => playerDefeatCount.value++,
      onCombatMessage: setCombatMessage,
      onCombatOccurred: recoverySystem.markCombat,
      onFeedback: onFeedback,
    );
    autoHuntSystem = AutoHuntSystem(
      player: player,
      fishProvider: () => activeNpcFish,
      onStopped: (reason) => setCombatMessage('AUTO $reason'),
    );
  }

  static const Rect fieldBounds = Rect.fromLTRB(-640, -850, 640, 850);

  final PlayerFishComponent player;
  final void Function(GameFeedbackEvent event) onFeedback;
  final ValueNotifier<int> npcCount = ValueNotifier<int>(0);
  final ValueNotifier<int> consumedFishCount = ValueNotifier<int>(0);
  final ValueNotifier<int> playerDefeatCount = ValueNotifier<int>(0);
  final ValueNotifier<String> combatMessage = ValueNotifier<String>('');
  final ValueNotifier<RegionDiscoveryEvent?> regionDiscoveryEvent =
      ValueNotifier<RegionDiscoveryEvent?>(null);
  late final CombatSystem combatSystem;
  late final AutoHuntSystem autoHuntSystem;
  late final RecoverySystem recoverySystem;

  NpcSpawnSystem? _spawnSystem;
  RegionDiscoverySystem? _regionDiscoverySystem;
  List<FishSpecies> _species = const [];
  double _combatMessageRemaining = 0;
  double? _restoredHp;

  List<NpcFishComponent> get activeNpcFish =>
      _spawnSystem?.activeFish ?? const [];
  List<FishSpecies> get species => _species;
  RegionDefinition? currentRegion;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await addAll([
      OceanBackdrop(),
      FieldBoundaryComponent(bounds: fieldBounds),
      combatSystem,
      recoverySystem,
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

  void _handleFishConsumed(NpcFishComponent fish) {
    consumedFishCount.value++;
    final result = player.consume(fish.species);
    if (result.unlockedSpecies) {
      _celebrate(ImpactEffect.unlock, GameFeedbackEvent.unlock);
      setCombatMessage('SPECIES UNLOCK!  ${fish.species.displayName}');
      return;
    }
    if (result.leveledUp) {
      _celebrate(ImpactEffect.levelUp, GameFeedbackEvent.levelUp);
      setCombatMessage('LEVEL UP!  LV.${player.progress.level}');
      return;
    }
    setCombatMessage(
      '+${result.expGained} EXP  +${result.fullnessGained.toInt()} FULL',
    );
  }

  void _celebrate(ImpactEffect effect, GameFeedbackEvent feedback) {
    add(
      ImpactBurstComponent(position: player.position.clone(), effect: effect),
    );
    onFeedback(feedback);
  }

  Future<void> initializeSpecies(List<FishSpecies> species) async {
    if (_spawnSystem != null) {
      return;
    }
    _species = List.unmodifiable(species);
    final currentSpeciesId = player.progress.currentSpeciesId;
    if (currentSpeciesId != PlayerProgress.starterSpeciesId) {
      final current = species
          .where((item) => item.id == currentSpeciesId)
          .firstOrNull;
      player.equipSpecies(current);
    }
    final restoredHp = _restoredHp;
    if (restoredHp != null) {
      player.hp.value = restoredHp.clamp(1, player.maxHp);
      _restoredHp = null;
      player.progressChanges.value++;
    }
    final system = NpcSpawnSystem(fishWorld: this, species: species);
    _spawnSystem = system;
    await add(system);
  }

  Future<void> initializeRegion(RegionDefinition region) async {
    if (_regionDiscoverySystem != null) {
      return;
    }
    currentRegion = region;
    if (player.progress.discoverRegion(region.id)) {
      player.progressChanges.value++;
    }
    final system = RegionDiscoverySystem(
      region: region,
      player: player,
      onDiscovered: _handleRegionDiscovery,
    );
    _regionDiscoverySystem = system;
    await add(system);
  }

  void _handleRegionDiscovery(RegionDiscoveryEvent event) {
    regionDiscoveryEvent.value = event;
    setCombatMessage(
      event.completedRegion
          ? 'REGION COMPLETE!  ${event.pointName}'
          : 'DISCOVERED!  ${event.pointName}',
    );
  }

  void restoreSave(PlayerSaveData data) {
    player.progress.restore(
      level: data.level,
      exp: data.exp,
      fullness: data.fullness,
      currentSpeciesId: data.currentSpeciesId,
      eatenCountBySpeciesId: data.eatenCountBySpeciesId,
      unlockedSpeciesIds: data.unlockedSpeciesIds,
      discoveredSpeciesIds: data.discoveredSpeciesIds,
      discoveredRegionIds: data.discoveredRegionIds,
      discoveredPointIdsByRegionId: data.discoveredPointIdsByRegionId,
    );
    _restoredHp = data.hp;
  }

  SpeciesChangeResult changeSpecies(String speciesId) {
    if (recoverySystem.isCombatLocked) {
      setCombatMessage('CANNOT CHANGE IN COMBAT');
      return SpeciesChangeResult.inCombat;
    }
    final species = speciesId == PlayerProgress.starterSpeciesId
        ? null
        : _species.where((item) => item.id == speciesId).firstOrNull;
    if (speciesId != PlayerProgress.starterSpeciesId && species == null) {
      return SpeciesChangeResult.notFound;
    }
    if (!player.equipSpecies(species)) {
      setCombatMessage('SPECIES LOCKED');
      return SpeciesChangeResult.locked;
    }
    setCombatMessage('CHANGED  ${player.currentSpeciesName}');
    return SpeciesChangeResult.success;
  }

  @override
  void onRemove() {
    npcCount.dispose();
    consumedFishCount.dispose();
    playerDefeatCount.dispose();
    combatMessage.dispose();
    regionDiscoveryEvent.dispose();
    super.onRemove();
  }
}

enum SpeciesChangeResult { success, locked, inCombat, notFound }
