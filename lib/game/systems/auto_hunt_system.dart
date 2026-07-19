import 'package:fish_growth_rpg/domain/rules/auto_hunt_rules.dart';
import 'package:fish_growth_rpg/game/components/npc_fish_component.dart';
import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

class AutoHuntSystem extends Component {
  AutoHuntSystem({
    required this.player,
    required this.fishProvider,
    required this.onStopped,
    this.speedMultiplier = 0.75,
    this.lowHpRatio = 0.35,
    this.dangerDistance = 150,
    this.scanInterval = 0.15,
  });

  final PlayerFishComponent player;
  final List<NpcFishComponent> Function() fishProvider;
  final void Function(String reason) onStopped;
  final double speedMultiplier;
  final double lowHpRatio;
  final double dangerDistance;
  final double scanInterval;

  final ValueNotifier<bool> enabled = ValueNotifier<bool>(false);
  final ValueNotifier<String> status = ValueNotifier<String>('OFF');

  NpcFishComponent? _target;
  double _scanRemaining = 0;

  NpcFishComponent? get target => _target;

  void setEnabled(bool value, {String stoppedReason = 'OFF'}) {
    if (!value) {
      _stop(stoppedReason, notify: false);
      return;
    }
    enabled.value = true;
    status.value = 'SEARCH';
    _scanRemaining = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!enabled.value) {
      return;
    }
    if (player.hp.value / player.maxHp <= lowHpRatio) {
      _stop('LOW HP');
      return;
    }

    final fish = fishProvider();
    final dangerDistanceSquared = dangerDistance * dangerDistance;
    if (AutoHuntRules.hasNearbyDanger<NpcFishComponent>(
      candidates: fish,
      playerSize: player.gameplaySize,
      dangerDistanceSquared: dangerDistanceSquared,
      isAlive: (candidate) => candidate.isAlive,
      npcSize: (candidate) => candidate.gameplaySize,
      distanceSquared: _distanceSquared,
    )) {
      _stop('DANGER');
      return;
    }

    _scanRemaining -= dt;
    if (_scanRemaining <= 0 || !_isValidTarget(_target)) {
      _target = AutoHuntRules.nearestEdible<NpcFishComponent>(
        candidates: fish,
        playerSize: player.gameplaySize,
        isAlive: (candidate) => candidate.isAlive,
        npcSize: (candidate) => candidate.gameplaySize,
        distanceSquared: _distanceSquared,
      );
      _scanRemaining = scanInterval;
    }

    final target = _target;
    if (target == null) {
      player.movement.clearAutomaticSteering();
      status.value = 'SEARCH';
      return;
    }
    final direction = target.position - player.position;
    player.movement.setAutomaticSteering(
      direction,
      speedMultiplier: speedMultiplier,
    );
    status.value = 'HUNT';
  }

  @override
  void onRemove() {
    player.movement.clearAutomaticSteering();
    enabled.dispose();
    status.dispose();
    super.onRemove();
  }

  bool _isValidTarget(NpcFishComponent? candidate) {
    return candidate != null &&
        candidate.isAlive &&
        !candidate.isRemoving &&
        !candidate.isRemoved;
  }

  double _distanceSquared(NpcFishComponent fish) {
    return fish.position.distanceToSquared(player.position);
  }

  void _stop(String reason, {bool notify = true}) {
    final wasEnabled = enabled.value;
    enabled.value = false;
    status.value = reason;
    _target = null;
    if (reason == 'DANGER' || reason == 'LOW HP') {
      player.movement.haltAutomaticMovement();
    } else {
      player.movement.clearAutomaticSteering();
    }
    if (notify && wasEnabled) {
      onStopped(reason);
    }
  }
}
