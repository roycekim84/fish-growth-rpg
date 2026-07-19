import 'dart:ui';

import 'package:fish_growth_rpg/domain/rules/combat_rules.dart';
import 'package:fish_growth_rpg/game/components/impact_burst_component.dart';
import 'package:fish_growth_rpg/game/components/npc_fish_component.dart';
import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:flame/components.dart';

class CombatSystem extends Component {
  CombatSystem({
    required this.player,
    required this.onFishConsumed,
    required this.onPlayerDefeated,
    required this.onCombatMessage,
    this.attackInterval = 0.75,
  });

  final PlayerFishComponent player;
  final void Function(NpcFishComponent fish) onFishConsumed;
  final void Function() onPlayerDefeated;
  final void Function(String message) onCombatMessage;
  final double attackInterval;

  final Set<NpcFishComponent> _activeContacts = {};
  final Map<NpcFishComponent, double> _nextAttackAt = {};

  double _elapsed = 0;
  double _playerInvulnerableUntil = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    player.onContactStart = _handleContactStart;
    player.onContactEnd = _handleContactEnd;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    for (final fish in _activeContacts.toList(growable: false)) {
      if (!fish.isAlive || fish.isRemoving || fish.isRemoved) {
        _forget(fish);
        continue;
      }
      if (_elapsed >= (_nextAttackAt[fish] ?? 0)) {
        _resolveContact(fish);
      }
    }
  }

  @override
  void onRemove() {
    player.onContactStart = null;
    player.onContactEnd = null;
    super.onRemove();
  }

  void _handleContactStart(PositionComponent other) {
    if (other is! NpcFishComponent || !other.isAlive) {
      return;
    }
    _activeContacts.add(other);
    if (_elapsed >= (_nextAttackAt[other] ?? 0)) {
      _resolveContact(other);
    }
  }

  void _handleContactEnd(PositionComponent other) {
    if (other is NpcFishComponent) {
      _activeContacts.remove(other);
    }
  }

  void _resolveContact(NpcFishComponent fish) {
    if (!fish.isAlive) {
      _forget(fish);
      return;
    }

    final relation = CombatRules.relation(
      playerSize: player.gameplaySize,
      npcSize: fish.gameplaySize,
    );
    _nextAttackAt[fish] = _elapsed + attackInterval;

    switch (relation) {
      case CombatRelation.instantConsume:
        _consume(fish);
      case CombatRelation.playerInDanger:
        _damagePlayer(fish.species.strength, attacker: fish);
      case CombatRelation.mutualCombat:
        final defeated = fish.takeDamage(player.strength);
        _impact(fish.position, const Color(0xFFFFD166));
        onCombatMessage(
          '-${player.strength.toInt()} ${fish.species.displayName}',
        );
        _damagePlayer(fish.species.strength, attacker: fish);
        if (defeated) {
          _consume(fish);
        }
    }
  }

  void _damagePlayer(double damage, {required NpcFishComponent attacker}) {
    if (_elapsed < _playerInvulnerableUntil) {
      return;
    }
    final defeated = player.takeDamage(damage);
    _impact(player.position, const Color(0xFFFF5C72));
    onCombatMessage('-${damage.toInt()} HP');
    if (!defeated) {
      return;
    }

    _activeContacts.clear();
    _nextAttackAt.clear();
    player.reviveAt(Vector2.zero());
    _playerInvulnerableUntil = _elapsed + 1.5;
    onCombatMessage('RESPAWN');
    onPlayerDefeated();
  }

  void _consume(NpcFishComponent fish) {
    if (!fish.markConsumed()) {
      return;
    }
    _impact(fish.position, const Color(0xFF5CFFB1));
    onCombatMessage('ATE ${fish.species.displayName}');
    onFishConsumed(fish);
    _forget(fish);
    fish.removeFromParent();
  }

  void _forget(NpcFishComponent fish) {
    _activeContacts.remove(fish);
    _nextAttackAt.remove(fish);
  }

  void _impact(Vector2 position, Color color) {
    parent?.add(ImpactBurstComponent(position: position.clone(), color: color));
  }
}
