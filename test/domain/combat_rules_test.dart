import 'package:fish_growth_rpg/domain/rules/combat_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CombatRules', () {
    test('instantly consumes fish at the 1.15 size threshold', () {
      expect(
        CombatRules.relation(playerSize: 1.15, npcSize: 1),
        CombatRelation.instantConsume,
      );
    });

    test('uses mutual combat between the size thresholds', () {
      expect(
        CombatRules.relation(playerSize: 1.149, npcSize: 1),
        CombatRelation.mutualCombat,
      );
      expect(
        CombatRules.relation(playerSize: 0.9, npcSize: 1),
        CombatRelation.mutualCombat,
      );
    });

    test('marks the player as in danger below the 0.9 threshold', () {
      expect(
        CombatRules.relation(playerSize: 0.899, npcSize: 1),
        CombatRelation.playerInDanger,
      );
    });
  });
}
