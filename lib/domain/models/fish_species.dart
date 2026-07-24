class FishSpecies {
  const FishSpecies({
    required this.id,
    required this.displayName,
    required this.description,
    required this.behaviorType,
    required this.maxHp,
    required this.strength,
    required this.dexterity,
    required this.intelligence,
    required this.speed,
    required this.size,
    required this.weight,
    required this.expReward,
    required this.fullnessReward,
    required this.unlockEatCount,
    required this.maxSpawnCount,
    this.spawnCountByRegionId = const {},
    this.playerMaxHpMultiplier = 1,
    this.playerStrengthMultiplier = 1,
    this.playerSpeedMultiplier = 1,
    this.playerSizeMultiplier = 1,
    this.playerWeightMultiplier = 1,
    this.playerTraitDescription = '',
    this.playerAbilityId = '',
    this.playerAbilityName = '',
    this.playerAbilityDescription = '',
  });

  factory FishSpecies.fromJson(Map<String, dynamic> json) {
    return FishSpecies(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      behaviorType: json['behaviorType'] as String,
      maxHp: (json['maxHP'] as num).toDouble(),
      strength: (json['str'] as num).toDouble(),
      dexterity: (json['dex'] as num).toDouble(),
      intelligence: (json['int'] as num).toDouble(),
      speed: (json['spd'] as num).toDouble(),
      size: (json['size'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      expReward: json['expReward'] as int,
      fullnessReward: (json['fullnessReward'] as num).toDouble(),
      unlockEatCount: json['unlockEatCount'] as int,
      maxSpawnCount: json['maxSpawnCount'] as int,
      spawnCountByRegionId: Map<String, int>.unmodifiable(
        (json['spawnCountByRegionId'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key, value as int),
        ),
      ),
      playerMaxHpMultiplier:
          (json['playerMaxHPMultiplier'] as num?)?.toDouble() ?? 1,
      playerStrengthMultiplier:
          (json['playerStrengthMultiplier'] as num?)?.toDouble() ?? 1,
      playerSpeedMultiplier:
          (json['playerSpeedMultiplier'] as num?)?.toDouble() ?? 1,
      playerSizeMultiplier:
          (json['playerSizeMultiplier'] as num?)?.toDouble() ?? 1,
      playerWeightMultiplier:
          (json['playerWeightMultiplier'] as num?)?.toDouble() ?? 1,
      playerTraitDescription: json['playerTraitDescription'] as String? ?? '',
      playerAbilityId: json['playerAbilityId'] as String? ?? '',
      playerAbilityName: json['playerAbilityName'] as String? ?? '',
      playerAbilityDescription:
          json['playerAbilityDescription'] as String? ?? '',
    );
  }

  final String id;
  final String displayName;
  final String description;
  final String behaviorType;
  final double maxHp;
  final double strength;
  final double dexterity;
  final double intelligence;
  final double speed;
  final double size;
  final double weight;
  final int expReward;
  final double fullnessReward;
  final int unlockEatCount;
  final int maxSpawnCount;
  final Map<String, int> spawnCountByRegionId;
  final double playerMaxHpMultiplier;
  final double playerStrengthMultiplier;
  final double playerSpeedMultiplier;
  final double playerSizeMultiplier;
  final double playerWeightMultiplier;
  final String playerTraitDescription;
  final String playerAbilityId;
  final String playerAbilityName;
  final String playerAbilityDescription;

  int spawnCountForRegion(String? regionId) {
    return spawnCountByRegionId[regionId] ?? maxSpawnCount;
  }
}
