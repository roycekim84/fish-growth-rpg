import 'package:fish_growth_rpg/domain/rules/combat_rules.dart';

class AutoHuntRules {
  const AutoHuntRules._();

  static T? nearestEdible<T>({
    required Iterable<T> candidates,
    required double playerSize,
    required bool Function(T candidate) isAlive,
    required double Function(T candidate) npcSize,
    required double Function(T candidate) distanceSquared,
  }) {
    T? nearest;
    var nearestDistance = double.infinity;
    for (final candidate in candidates) {
      if (!isAlive(candidate) ||
          CombatRules.relation(
                playerSize: playerSize,
                npcSize: npcSize(candidate),
              ) !=
              CombatRelation.instantConsume) {
        continue;
      }
      final distance = distanceSquared(candidate);
      if (distance < nearestDistance) {
        nearest = candidate;
        nearestDistance = distance;
      }
    }
    return nearest;
  }

  static bool hasNearbyDanger<T>({
    required Iterable<T> candidates,
    required double playerSize,
    required double dangerDistanceSquared,
    required bool Function(T candidate) isAlive,
    required double Function(T candidate) npcSize,
    required double Function(T candidate) distanceSquared,
  }) {
    return candidates.any(
      (candidate) =>
          isAlive(candidate) &&
          distanceSquared(candidate) <= dangerDistanceSquared &&
          CombatRules.relation(
                playerSize: playerSize,
                npcSize: npcSize(candidate),
              ) ==
              CombatRelation.playerInDanger,
    );
  }
}
