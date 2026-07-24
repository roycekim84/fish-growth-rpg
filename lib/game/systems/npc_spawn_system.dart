import 'dart:math' as math;

import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:fish_growth_rpg/game/components/npc_fish_component.dart';
import 'package:fish_growth_rpg/game/fish_world.dart';
import 'package:fish_growth_rpg/game/systems/spawn_position_picker.dart';
import 'package:flame/components.dart';

class NpcSpawnSystem extends Component {
  NpcSpawnSystem({
    required this.fishWorld,
    required this.species,
    int? randomSeed,
    this.respawnInterval = 1,
  }) : _random = math.Random(randomSeed),
       _positionPicker = SpawnPositionPicker(
         fieldBounds: FishWorld.fieldBounds,
         minimumPlayerDistance: 280,
         edgePadding: 48,
         random: math.Random(randomSeed),
       );

  final FishWorld fishWorld;
  final List<FishSpecies> species;
  final double respawnInterval;
  final math.Random _random;
  final SpawnPositionPicker _positionPicker;
  final List<NpcFishComponent> _activeFish = [];

  double _respawnCooldown = 0;

  List<NpcFishComponent> get activeFish => List.unmodifiable(_activeFish);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _fillPopulation();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _respawnCooldown -= dt;
    if (_respawnCooldown <= 0) {
      _respawnCooldown = respawnInterval;
      _fillPopulation();
    }
  }

  int countForSpecies(String speciesId) {
    return _activeFish.where((fish) => fish.species.id == speciesId).length;
  }

  void refreshForCurrentRegion() {
    final fishToRemove = List<NpcFishComponent>.of(_activeFish);
    _activeFish.clear();
    for (final fish in fishToRemove) {
      fish.removeFromParent();
    }
    fishWorld.npcCount.value = 0;
    _respawnCooldown = respawnInterval;
    _fillPopulation();
  }

  void _fillPopulation() {
    for (final definition in species) {
      final targetCount = definition.spawnCountForRegion(
        fishWorld.currentRegion?.id,
      );
      final missing = targetCount - countForSpecies(definition.id);
      for (var i = 0; i < missing; i++) {
        final position = _positionPicker.pick(
          playerPosition: fishWorld.player.position,
          occupiedPositions: _activeFish.map((fish) => fish.position),
        );
        if (position == null) {
          break;
        }
        final fish = NpcFishComponent(
          species: definition,
          player: fishWorld.player,
          fieldBounds: FishWorld.fieldBounds,
          position: position,
          random: math.Random(_random.nextInt(1 << 31)),
          onRemoved: _handleFishRemoved,
        );
        _activeFish.add(fish);
        fishWorld.add(fish);
      }
    }
    fishWorld.npcCount.value = _activeFish.length;
  }

  void _handleFishRemoved(NpcFishComponent fish) {
    _activeFish.remove(fish);
    if (!fishWorld.isRemoving && !fishWorld.isRemoved) {
      fishWorld.npcCount.value = _activeFish.length;
    }
  }
}
