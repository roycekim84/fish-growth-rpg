import 'package:fish_growth_rpg/domain/models/quest_definition.dart';

class PlayerProgress {
  PlayerProgress({
    this.level = 1,
    this.exp = 0,
    this.fullness = 50,
    this.currentSpeciesId = starterSpeciesId,
    this.currentRegionId = defaultRegionId,
    Map<String, int>? eatenCountBySpeciesId,
    Set<String>? unlockedSpeciesIds,
    Set<String>? discoveredSpeciesIds,
    Set<String>? discoveredRegionIds,
    Map<String, Set<String>>? discoveredPointIdsByRegionId,
    Map<String, QuestStatus>? questStatusById,
    Set<String>? unlockedRegionIds,
    Set<String>? defeatedBossIds,
  }) : eatenCountBySpeciesId = {...?eatenCountBySpeciesId},
       unlockedSpeciesIds = {starterSpeciesId, ...?unlockedSpeciesIds},
       discoveredSpeciesIds = {...?discoveredSpeciesIds},
       discoveredRegionIds = {...?discoveredRegionIds},
       discoveredPointIdsByRegionId = {
         for (final entry
             in discoveredPointIdsByRegionId?.entries ??
                 const <MapEntry<String, Set<String>>>[])
           entry.key: {...entry.value},
       },
       questStatusById = {...?questStatusById},
       unlockedRegionIds = {'ocean_shallows', ...?unlockedRegionIds},
       defeatedBossIds = {...?defeatedBossIds};

  static const String starterSpeciesId = 'starter_fish';
  static const String defaultRegionId = 'ocean_shallows';
  static const double maxFullness = 100;
  static const double baseMaxHp = 40;
  static const double baseStrength = 3;
  static const double baseSize = 0.8;
  static const double baseWeight = 1;

  int level;
  int exp;
  double fullness;
  String currentSpeciesId;
  String currentRegionId;
  final Map<String, int> eatenCountBySpeciesId;
  final Set<String> unlockedSpeciesIds;
  final Set<String> discoveredSpeciesIds;
  final Set<String> discoveredRegionIds;
  final Map<String, Set<String>> discoveredPointIdsByRegionId;
  final Map<String, QuestStatus> questStatusById;
  final Set<String> unlockedRegionIds;
  final Set<String> defeatedBossIds;

  int get requiredExp => 20 + level * 10;
  double get maxHp => baseMaxHp + (level - 1) * 5;
  double get strength => baseStrength + (level - 1);
  double get size => baseSize + (level - 1) * 0.03;
  double get weight => baseWeight + (level - 1) * 0.05;
  int get totalEaten => eatenCountBySpeciesId.values.fold(0, (a, b) => a + b);

  ConsumptionResult recordConsumption({
    required String speciesId,
    required int expReward,
    required double fullnessReward,
    int unlockEatCount = 100,
  }) {
    final previousLevel = level;
    final previousMaxHp = maxHp;
    final previousFullness = fullness;
    exp += expReward;
    fullness = (fullness + fullnessReward).clamp(0, maxFullness);
    eatenCountBySpeciesId.update(
      speciesId,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    discoveredSpeciesIds.add(speciesId);
    final shouldUnlock =
        eatenCountBySpeciesId[speciesId]! >= unlockEatCount &&
        !unlockedSpeciesIds.contains(speciesId);
    if (shouldUnlock) {
      unlockedSpeciesIds.add(speciesId);
    }

    while (exp >= requiredExp) {
      exp -= requiredExp;
      level++;
    }

    return ConsumptionResult(
      levelsGained: level - previousLevel,
      maxHpGained: maxHp - previousMaxHp,
      expGained: expReward,
      fullnessGained: fullness - previousFullness,
      speciesEatCount: eatenCountBySpeciesId[speciesId]!,
      newlyUnlockedSpeciesId: shouldUnlock ? speciesId : null,
    );
  }

  bool isSpeciesUnlocked(String speciesId) {
    return unlockedSpeciesIds.contains(speciesId);
  }

  bool changeSpecies(String speciesId) {
    if (!isSpeciesUnlocked(speciesId)) {
      return false;
    }
    currentSpeciesId = speciesId;
    return true;
  }

  bool discoverRegion(String regionId) {
    if (regionId.isEmpty) {
      return false;
    }
    return discoveredRegionIds.add(regionId);
  }

  bool setCurrentRegion(String regionId) {
    if (regionId.isEmpty || currentRegionId == regionId) {
      return false;
    }
    currentRegionId = regionId;
    return true;
  }

  bool isRegionUnlocked(String regionId) =>
      unlockedRegionIds.contains(regionId);

  bool unlockRegion(String regionId) {
    if (regionId.isEmpty) {
      return false;
    }
    return unlockedRegionIds.add(regionId);
  }

  bool defeatBoss(String bossId) {
    if (bossId.isEmpty) {
      return false;
    }
    return defeatedBossIds.add(bossId);
  }

  bool hasDiscoveredPoint(String regionId, String pointId) {
    return discoveredPointIdsByRegionId[regionId]?.contains(pointId) ?? false;
  }

  bool discoverPoint(String regionId, String pointId) {
    if (regionId.isEmpty || pointId.isEmpty) {
      return false;
    }
    discoverRegion(regionId);
    return discoveredPointIdsByRegionId
        .putIfAbsent(regionId, () => <String>{})
        .add(pointId);
  }

  Set<String> discoveredPointIdsForRegion(String regionId) {
    return Set.unmodifiable(discoveredPointIdsByRegionId[regionId] ?? const {});
  }

  QuestStatus questStatus(String questId) {
    return questStatusById[questId] ?? QuestStatus.inactive;
  }

  bool startQuest(String questId) {
    if (questStatus(questId) != QuestStatus.inactive) {
      return false;
    }
    questStatusById[questId] = QuestStatus.active;
    return true;
  }

  bool completeQuest(String questId) {
    if (questStatus(questId) != QuestStatus.active) {
      return false;
    }
    questStatusById[questId] = QuestStatus.completed;
    return true;
  }

  bool unlockSpeciesFromQuest(String speciesId) {
    return unlockedSpeciesIds.add(speciesId);
  }

  void restore({
    required int level,
    required int exp,
    required double fullness,
    required String currentSpeciesId,
    String currentRegionId = defaultRegionId,
    required Map<String, int> eatenCountBySpeciesId,
    required Set<String> unlockedSpeciesIds,
    required Set<String> discoveredSpeciesIds,
    Set<String> discoveredRegionIds = const {},
    Map<String, Set<String>> discoveredPointIdsByRegionId = const {},
    Map<String, QuestStatus> questStatusById = const {},
    Set<String> unlockedRegionIds = const {},
    Set<String> defeatedBossIds = const {},
  }) {
    this.level = level < 1 ? 1 : level;
    this.exp = exp < 0 ? 0 : exp;
    this.fullness = fullness.clamp(0, maxFullness);
    this.currentSpeciesId = currentSpeciesId;
    this.currentRegionId = currentRegionId.isEmpty
        ? defaultRegionId
        : currentRegionId;
    this.eatenCountBySpeciesId
      ..clear()
      ..addAll(eatenCountBySpeciesId);
    this.unlockedSpeciesIds
      ..clear()
      ..add(starterSpeciesId)
      ..addAll(unlockedSpeciesIds);
    this.discoveredSpeciesIds
      ..clear()
      ..addAll(discoveredSpeciesIds);
    this.discoveredRegionIds
      ..clear()
      ..addAll(discoveredRegionIds);
    this.discoveredPointIdsByRegionId
      ..clear()
      ..addAll({
        for (final entry in discoveredPointIdsByRegionId.entries)
          entry.key: {...entry.value},
      });
    this.questStatusById
      ..clear()
      ..addAll(questStatusById);
    this.unlockedRegionIds
      ..clear()
      ..add('ocean_shallows')
      ..addAll(unlockedRegionIds);
    this.defeatedBossIds
      ..clear()
      ..addAll(defeatedBossIds);
  }

  double consumeFullness(double requestedAmount) {
    if (requestedAmount <= 0 || fullness <= 0) {
      return 0;
    }
    final consumed = requestedAmount.clamp(0, fullness).toDouble();
    fullness -= consumed;
    return consumed;
  }
}

class ConsumptionResult {
  const ConsumptionResult({
    required this.levelsGained,
    required this.maxHpGained,
    required this.expGained,
    required this.fullnessGained,
    required this.speciesEatCount,
    required this.newlyUnlockedSpeciesId,
  });

  final int levelsGained;
  final double maxHpGained;
  final int expGained;
  final double fullnessGained;
  final int speciesEatCount;
  final String? newlyUnlockedSpeciesId;

  bool get leveledUp => levelsGained > 0;
  bool get unlockedSpecies => newlyUnlockedSpeciesId != null;
}
