import 'dart:async';
import 'dart:ui';

import 'package:fish_growth_rpg/data/save/player_save_repository.dart';
import 'package:fish_growth_rpg/data/regions/region_repository.dart';
import 'package:fish_growth_rpg/data/quests/quest_repository.dart';
import 'package:fish_growth_rpg/data/species/species_repository.dart';
import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:fish_growth_rpg/domain/models/player_save_data.dart';
import 'package:fish_growth_rpg/domain/models/region_definition.dart';
import 'package:fish_growth_rpg/domain/models/quest_definition.dart';
import 'package:fish_growth_rpg/game/components/drag_input_surface.dart';
import 'package:fish_growth_rpg/game/components/underwater_light_overlay.dart';
import 'package:fish_growth_rpg/game/fish_world.dart';
import 'package:fish_growth_rpg/game/services/game_feedback_service.dart';
import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

class FishGame extends FlameGame<FishWorld> {
  factory FishGame({
    PlayerSaveRepository saveRepository = const NoopPlayerSaveRepository(),
    DateTime Function()? now,
    GameFeedbackService? feedbackService,
  }) {
    final feedback = feedbackService ?? DeviceGameFeedbackService();
    final fishWorld = FishWorld(onFeedback: feedback.trigger);
    final camera = CameraComponent.withFixedResolution(
      world: fishWorld,
      width: logicalWidth,
      height: logicalHeight,
    );
    return FishGame._(
      fishWorld,
      camera,
      saveRepository,
      now ?? DateTime.now,
      feedback,
    );
  }

  FishGame._(
    FishWorld world,
    CameraComponent camera,
    this._saveRepository,
    this._now,
    this._feedbackService,
  ) : super(world: world, camera: camera);

  static const double logicalWidth = 360;
  static const double logicalHeight = 640;
  static const String collectionOverlayId = 'collection';
  static const String speciesChangeOverlayId = 'species-change';
  static const String questOverlayId = 'quests';

  final ValueNotifier<int> loadedSpeciesCount = ValueNotifier<int>(0);
  final ValueNotifier<bool> boostState = ValueNotifier<bool>(false);
  final ValueNotifier<SaveStatus> saveStatus = ValueNotifier<SaveStatus>(
    SaveStatus.loading,
  );
  List<FishSpecies> species = const [];
  List<RegionDefinition> regions = const [];
  List<QuestDefinition> quests = const [];

  final PlayerSaveRepository _saveRepository;
  final DateTime Function() _now;
  final GameFeedbackService _feedbackService;
  Timer? _saveDebounce;
  Future<void> _pendingSave = Future<void>.value();
  bool _saveReady = false;
  bool _isRemoved = false;

  @override
  Color backgroundColor() => const Color(0xFF071A2D);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    unawaited(_feedbackService.preload());
    final loadResult = await _saveRepository.load();
    final savedData = loadResult.data;
    if (savedData != null) {
      world.restoreSave(savedData);
    }
    species = await SpeciesRepository().loadAll();
    loadedSpeciesCount.value = species.length;
    await world.initializeSpecies(species);
    regions = await RegionRepository().loadAll();
    await world.initializeRegion(regions.first);
    quests = await QuestRepository().loadAll();
    await world.initializeQuests(quests);
    await world.initializeBoss();
    world.playerDefeatCount.addListener(_handlePlayerDefeat);
    await camera.viewport.addAll([
      UnderwaterLightOverlay(logicalSize: Vector2(logicalWidth, logicalHeight)),
      DragInputSurface(
        movement: world.player.movement,
        onManualInput: stopAutoHuntForManualInput,
        logicalSize: Vector2(logicalWidth, logicalHeight),
      ),
    ]);
    camera.follow(world.player, maxSpeed: 420, snap: true);
    world.player.progressChanges.addListener(_scheduleSave);
    world.player.hp.addListener(_scheduleSave);
    _saveReady = loadResult.state != SaveLoadState.unsupportedVersion;
    saveStatus.value = switch (loadResult.state) {
      SaveLoadState.loaded => SaveStatus.loaded,
      SaveLoadState.recoveredCorrupt => SaveStatus.recovered,
      SaveLoadState.unsupportedVersion => SaveStatus.unsupported,
      SaveLoadState.empty => SaveStatus.ready,
    };
  }

  void setBoosting(bool value) {
    if (value && world.autoHuntSystem.enabled.value) {
      world.autoHuntSystem.setEnabled(false, stoppedReason: 'MANUAL');
    }
    if (boostState.value == value) {
      return;
    }
    world.player.movement.setBoosting(value);
    boostState.value = value;
  }

  void setAutoHunting(bool value) {
    if (value) {
      setBoosting(false);
    }
    world.autoHuntSystem.setEnabled(value);
  }

  void stopAutoHuntForManualInput() {
    if (!world.autoHuntSystem.enabled.value) {
      return;
    }
    world.autoHuntSystem.setEnabled(false, stoppedReason: 'MANUAL');
    world.setCombatMessage('AUTO MANUAL');
  }

  void openCollection() {
    _openModal(collectionOverlayId);
  }

  bool openQuestLog() {
    final system = world.questSystem;
    if (system == null || !system.canTalk.value) {
      world.setCombatMessage('FIND NURI IN THE SHALLOWS');
      return false;
    }
    _openModal(questOverlayId);
    return true;
  }

  bool startNextQuest() => world.startNextQuest();

  bool openSpeciesChange() {
    if (world.recoverySystem.isCombatLocked) {
      world.setCombatMessage('CANNOT CHANGE IN COMBAT');
      return false;
    }
    _openModal(speciesChangeOverlayId);
    return true;
  }

  void closeModal(String overlayId) {
    overlays.remove(overlayId);
    if (!overlays.isActive(collectionOverlayId) &&
        !overlays.isActive(speciesChangeOverlayId) &&
        !overlays.isActive(questOverlayId)) {
      resumeEngine();
    }
  }

  SpeciesChangeResult changeSpecies(String speciesId) {
    final result = world.changeSpecies(speciesId);
    if (result == SpeciesChangeResult.success) {
      unawaited(saveNow());
    }
    return result;
  }

  Future<void> saveNow() {
    if (!_saveReady) {
      return Future<void>.value();
    }
    _saveDebounce?.cancel();
    final snapshot = PlayerSaveData.capture(
      progress: world.player.progress,
      hp: world.player.hp.value,
      savedAt: _now(),
    );
    _pendingSave = _pendingSave.then((_) => _writeSave(snapshot));
    return _pendingSave;
  }

  void _openModal(String overlayId) {
    setBoosting(false);
    world.autoHuntSystem.setEnabled(false);
    pauseEngine();
    overlays.add(overlayId);
  }

  void _handlePlayerDefeat() {
    setBoosting(false);
    world.autoHuntSystem.setEnabled(false, stoppedReason: 'KO');
  }

  void _scheduleSave() {
    if (!_saveReady || _isRemoved) {
      return;
    }
    saveStatus.value = SaveStatus.pending;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 700), () {
      unawaited(saveNow());
    });
  }

  Future<void> _writeSave(PlayerSaveData snapshot) async {
    if (!_isRemoved) {
      saveStatus.value = SaveStatus.saving;
    }
    try {
      await _saveRepository.save(snapshot);
      if (!_isRemoved) {
        saveStatus.value = SaveStatus.saved;
      }
    } on Object {
      if (!_isRemoved) {
        saveStatus.value = SaveStatus.failed;
      }
    }
  }

  @override
  void onRemove() {
    _isRemoved = true;
    _saveReady = false;
    _saveDebounce?.cancel();
    world.player.progressChanges.removeListener(_scheduleSave);
    world.player.hp.removeListener(_scheduleSave);
    world.playerDefeatCount.removeListener(_handlePlayerDefeat);
    loadedSpeciesCount.dispose();
    boostState.dispose();
    saveStatus.dispose();
    super.onRemove();
  }
}

enum SaveStatus {
  loading('LOAD'),
  ready('LOCAL'),
  loaded('LOADED'),
  recovered('RECOVERED'),
  unsupported('NEW SAVE'),
  pending('PENDING'),
  saving('SAVING'),
  saved('SAVED'),
  failed('SAVE ERR');

  const SaveStatus(this.label);

  final String label;
}
