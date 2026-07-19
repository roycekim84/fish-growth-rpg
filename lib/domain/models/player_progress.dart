class PlayerProgress {
  PlayerProgress({
    this.level = 1,
    this.exp = 0,
    this.fullness = 50,
    Map<String, int>? eatenCountBySpeciesId,
  }) : eatenCountBySpeciesId = {...?eatenCountBySpeciesId};

  static const double maxFullness = 100;
  static const double baseMaxHp = 40;
  static const double baseStrength = 3;
  static const double baseSize = 0.8;
  static const double baseWeight = 1;

  int level;
  int exp;
  double fullness;
  final Map<String, int> eatenCountBySpeciesId;

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
    );
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
  });

  final int levelsGained;
  final double maxHpGained;
  final int expGained;
  final double fullnessGained;
  final int speciesEatCount;

  bool get leveledUp => levelsGained > 0;
}
