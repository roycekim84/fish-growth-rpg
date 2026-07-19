import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

class RecoverySystem extends Component {
  RecoverySystem({
    required this.player,
    required this.onRecoveryStarted,
    this.idleDelay = 1.5,
    this.combatCooldown = 1,
    this.idleVelocityThreshold = 4,
  });

  final PlayerFishComponent player;
  final void Function() onRecoveryStarted;
  final double idleDelay;
  final double combatCooldown;
  final double idleVelocityThreshold;

  final ValueNotifier<bool> isRecovering = ValueNotifier<bool>(false);

  double _elapsed = 0;
  double _idleDuration = 0;
  double _lastCombatAt = double.negativeInfinity;

  double get idleDuration => _idleDuration;
  bool get isCombatLocked => _elapsed - _lastCombatAt < combatCooldown;

  void markCombat() {
    _lastCombatAt = _elapsed;
    _setRecovering(false);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dt <= 0) {
      return;
    }
    _elapsed += dt;

    final movement = player.movement;
    final hasMovementInput =
        movement.isDragging ||
        movement.isAutomaticSteering ||
        !movement.inputDirection.isZero();
    final isNearlyStopped = movement.velocity.length <= idleVelocityThreshold;
    if (hasMovementInput || !isNearlyStopped || movement.isBoosting) {
      _idleDuration = 0;
      _setRecovering(false);
      return;
    }

    _idleDuration += dt;
    final canRecover =
        _idleDuration >= idleDelay &&
        _elapsed - _lastCombatAt >= combatCooldown &&
        player.hp.value < player.maxHp &&
        player.progress.fullness > 0;
    if (!canRecover) {
      _setRecovering(false);
      return;
    }

    final hpRecovered = player.recover(dt);
    _setRecovering(hpRecovered > 0);
  }

  @override
  void onRemove() {
    player.setRecovering(false);
    isRecovering.dispose();
    super.onRemove();
  }

  void _setRecovering(bool value) {
    if (isRecovering.value == value) {
      return;
    }
    isRecovering.value = value;
    player.setRecovering(value);
    if (value) {
      onRecoveryStarted();
    }
  }
}
