import 'dart:async';
import 'dart:ui';

import 'package:fish_growth_rpg/domain/models/player_save_data.dart';
import 'package:fish_growth_rpg/domain/models/player_progress.dart';
import 'package:fish_growth_rpg/domain/models/region_definition.dart';
import 'package:fish_growth_rpg/domain/models/quest_definition.dart';
import 'package:fish_growth_rpg/game/components/field_boundary_component.dart';
import 'package:fish_growth_rpg/game/components/ability_gate_component.dart';
import 'package:fish_growth_rpg/game/components/boss_arena_boundary_component.dart';
import 'package:fish_growth_rpg/game/components/boss_fish_component.dart';
import 'package:fish_growth_rpg/game/components/impact_burst_component.dart';
import 'package:fish_growth_rpg/game/components/ocean_backdrop.dart';
import 'package:fish_growth_rpg/game/components/npc_fish_component.dart';
import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:fish_growth_rpg/game/components/quest_npc_component.dart';
import 'package:fish_growth_rpg/game/components/region_gate_component.dart';
import 'package:fish_growth_rpg/game/systems/auto_hunt_system.dart';
import 'package:fish_growth_rpg/game/systems/combat_system.dart';
import 'package:fish_growth_rpg/game/systems/npc_spawn_system.dart';
import 'package:fish_growth_rpg/game/systems/recovery_system.dart';
import 'package:fish_growth_rpg/game/systems/region_discovery_system.dart';
import 'package:fish_growth_rpg/game/systems/quest_system.dart';
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
  final List<Component> _regionComponents = [];
  List<RegionDefinition> _regionCatalog = const [];
  QuestSystem? questSystem;
  BossFishComponent? boss;
  List<FishSpecies> _species = const [];
  double _combatMessageRemaining = 0;
  double? _restoredHp;
  final OceanBackdrop oceanBackdrop = OceanBackdrop();

  List<NpcFishComponent> get activeNpcFish =>
      _spawnSystem?.activeFish ?? const [];
  List<FishSpecies> get species => _species;
  RegionDefinition? currentRegion;
  static const Rect bossArenaBounds = Rect.fromLTRB(-620, -840, 620, -590);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await addAll([
      oceanBackdrop,
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
    if (fish is BossFishComponent) {
      _handleBossDefeated(fish);
      return;
    }
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
    if (currentRegion != null) {
      return;
    }
    await _activateRegion(region, spawnPosition: Vector2.zero());
  }

  void setRegionCatalog(List<RegionDefinition> regions) {
    _regionCatalog = List.unmodifiable(regions);
  }

  Future<void> enterRegion(String regionId) async {
    if (currentRegion?.id == regionId ||
        !player.progress.isRegionUnlocked(regionId)) {
      return;
    }
    final region = _regionCatalog
        .where((item) => item.id == regionId)
        .firstOrNull;
    if (region == null) {
      return;
    }
    await _activateRegion(region, spawnPosition: Vector2(0, 620));
    setCombatMessage('ENTERED!  ${region.displayName}');
  }

  Future<void> _activateRegion(
    RegionDefinition region, {
    required Vector2 spawnPosition,
  }) async {
    for (final component in _regionComponents) {
      component.removeFromParent();
    }
    _regionComponents.clear();
    currentRegion = region;
    final changedCurrentRegion = player.progress.setCurrentRegion(region.id);
    final discovered = player.progress.discoverRegion(region.id);
    final unlocked = player.progress.unlockRegion(region.id);
    if (discovered || unlocked || changedCurrentRegion) {
      player.progressChanges.value++;
    }
    player.position.setFrom(spawnPosition);
    player.movement.velocity.setZero();
    oceanBackdrop.setTheme(
      region.id == 'deep_sea'
          ? OceanBackdropTheme.deepSea
          : OceanBackdropTheme.shallows,
    );
    final discoverySystem = RegionDiscoverySystem(
      region: region,
      player: player,
      onDiscovered: _handleRegionDiscovery,
    );
    _regionComponents.add(discoverySystem);
    if (region.id == 'ocean_shallows') {
      final narrowCurrent = AbilityGateComponent(
        bounds: const Rect.fromLTRB(-640, -575, 640, -530),
        player: player,
        requiredAbilityId: 'narrow_current',
        label: 'NARROW CURRENT',
        onBlocked: (label) => setCombatMessage('$label REQUIRES SMALL FISH'),
      );
      final coralWall = AbilityGateComponent(
        bounds: const Rect.fromLTWH(400, 260, 160, 150),
        player: player,
        requiredAbilityId: 'coral_break',
        label: 'CORAL WALL',
        onBlocked: (label) => setCombatMessage('$label REQUIRES PUFFER'),
      );
      _regionComponents.addAll([narrowCurrent, coralWall]);
    }
    await addAll(_regionComponents);
  }

  Future<void> initializeBoss() async {
    if (currentRegion?.id != 'ocean_shallows' || boss != null) {
      return;
    }
    final arena = BossArenaBoundaryComponent(bounds: bossArenaBounds);
    final gate = RegionGateComponent(
      bounds: const Rect.fromLTRB(-190, -842, 190, -805),
      player: player,
      isUnlocked: () => player.progress.isRegionUnlocked('deep_sea'),
      onBlocked: () => setCombatMessage('DEFEAT THE CURRENT WARDEN'),
      onEnter: () => unawaited(enterRegion('deep_sea')),
    );
    final components = <Component>[arena, gate];
    if (!player.progress.defeatedBossIds.contains(BossFishComponent.bossId)) {
      final currentBoss = BossFishComponent(
        player: player,
        fieldBounds: bossArenaBounds,
        position: Vector2(-310, -705),
        onRemoved: (_) {},
      );
      boss = currentBoss;
      components.add(currentBoss);
    }
    _regionComponents.addAll(components);
    await addAll(components);
  }

  void _handleBossDefeated(BossFishComponent defeatedBoss) {
    if (!player.progress.defeatBoss(BossFishComponent.bossId)) {
      return;
    }
    player.progress.unlockRegion('deep_sea');
    player.progressChanges.value++;
    _celebrate(ImpactEffect.unlock, GameFeedbackEvent.unlock);
    setCombatMessage('WARDEN DEFEATED!  DEEP SEA OPEN');
    boss = null;
  }

  Future<void> initializeQuests(List<QuestDefinition> quests) async {
    if (questSystem != null || currentRegion == null) {
      return;
    }
    final npcPosition = Vector2(-90, -90);
    final system = QuestSystem(
      player: player,
      region: currentRegion!,
      quests: quests,
      npcPosition: npcPosition,
      onQuestCompleted: _handleQuestCompleted,
    );
    questSystem = system;
    await addAll([QuestNpcComponent(position: npcPosition), system]);
  }

  bool startNextQuest() {
    final system = questSystem;
    if (system == null || !system.startNextQuest()) {
      return false;
    }
    final quest = system.quests.firstWhere(
      (item) => player.progress.questStatus(item.id) == QuestStatus.active,
    );
    setCombatMessage('NEW QUEST!  ${quest.title}');
    return true;
  }

  void _handleQuestCompleted(QuestDefinition quest, bool unlockedSpecies) {
    if (unlockedSpecies) {
      _celebrate(ImpactEffect.unlock, GameFeedbackEvent.unlock);
    }
    setCombatMessage(
      unlockedSpecies
          ? 'QUEST CLEAR!  ${quest.rewardText}'
          : 'QUEST CLEAR!  ${quest.title}',
    );
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
      currentRegionId: data.currentRegionId,
      eatenCountBySpeciesId: data.eatenCountBySpeciesId,
      unlockedSpeciesIds: data.unlockedSpeciesIds,
      discoveredSpeciesIds: data.discoveredSpeciesIds,
      discoveredRegionIds: data.discoveredRegionIds,
      discoveredPointIdsByRegionId: data.discoveredPointIdsByRegionId,
      questStatusById: data.questStatusById,
      unlockedRegionIds: data.unlockedRegionIds,
      defeatedBossIds: data.defeatedBossIds,
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
