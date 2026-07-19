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
}
