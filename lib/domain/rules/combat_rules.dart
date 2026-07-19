enum CombatRelation { instantConsume, mutualCombat, playerInDanger }

class CombatRules {
  const CombatRules._();

  static CombatRelation relation({
    required double playerSize,
    required double npcSize,
  }) {
    if (playerSize >= npcSize * 1.15) {
      return CombatRelation.instantConsume;
    }
    if (playerSize < npcSize * 0.9) {
      return CombatRelation.playerInDanger;
    }
    return CombatRelation.mutualCombat;
  }
}
