import 'dart:math' as math;
import 'dart:ui';

import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:fish_growth_rpg/domain/models/player_progress.dart';
import 'package:fish_growth_rpg/game/components/pixel_fish_component.dart';
import 'package:fish_growth_rpg/game/controllers/player_movement_controller.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

class PlayerFishComponent extends PixelFishComponent with CollisionCallbacks {
  PlayerFishComponent({
    required super.position,
    required this.fieldBounds,
    PlayerMovementController? movement,
    PlayerProgress? progress,
  }) : movement = movement ?? PlayerMovementController(),
       progress = progress ?? PlayerProgress(),
       super(bodyColor: const Color(0xFF38E8D0), isPlayer: true);

  final Rect fieldBounds;
  final PlayerMovementController movement;
  final PlayerProgress progress;
  late final ValueNotifier<double> hp = ValueNotifier<double>(maxHp);
  final ValueNotifier<int> progressChanges = ValueNotifier<int>(0);

  void Function(PositionComponent other)? onContactStart;
  void Function(PositionComponent other)? onContactEnd;

  double get gameplaySize => progress.size;
  double get maxHp => progress.maxHp;
  double get strength => progress.strength;
  double get weight => progress.weight;
  bool get isAlive => hp.value > 0;

  double _facing = 1;
  double _hitFlashRemaining = 0;
  double _levelFlashRemaining = 0;
  double _recoveryPulse = 0;
  bool _isRecovering = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(
      CircleHitbox.relative(
        0.68,
        parentSize: size,
        collisionType: CollisionType.active,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _hitFlashRemaining = math.max(0, _hitFlashRemaining - dt);
    _levelFlashRemaining = math.max(0, _levelFlashRemaining - dt);
    _recoveryPulse += dt;
    movement.update(dt);
    position.addScaled(movement.velocity, math.min(dt, 1 / 20));
    _updateGrowthScale();
    _constrainToField();
    _updateFacing(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_hitFlashRemaining > 0) {
      canvas.drawRect(
        Rect.fromLTWH(2, 2, size.x - 4, size.y - 4),
        Paint()..color = const Color(0xAAFFFFFF),
      );
    }
    if (_isRecovering) {
      final pulse = 0.55 + math.sin(_recoveryPulse * 8) * 0.25;
      canvas.drawRect(
        Rect.fromLTWH(-2, -2, size.x + 4, size.y + 4),
        Paint()
          ..color = const Color(0xFF5CFFB1).withValues(alpha: pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    if (_levelFlashRemaining > 0) {
      canvas.drawRect(
        Rect.fromLTWH(-4, -4, size.x + 8, size.y + 8),
        Paint()
          ..color = const Color(
            0xFFFFF0B8,
          ).withValues(alpha: (_levelFlashRemaining / 1.2).clamp(0, 1))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    onContactStart?.call(other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    onContactEnd?.call(other);
  }

  bool takeDamage(double amount) {
    if (!isAlive || amount <= 0) {
      return !isAlive;
    }
    hp.value = (hp.value - amount).clamp(0, maxHp);
    _hitFlashRemaining = 0.14;
    return !isAlive;
  }

  ConsumptionResult consume(FishSpecies species) {
    final result = progress.recordConsumption(
      speciesId: species.id,
      expReward: species.expReward,
      fullnessReward: species.fullnessReward,
    );
    if (result.maxHpGained > 0) {
      hp.value = (hp.value + result.maxHpGained).clamp(0, maxHp);
    }
    if (result.leveledUp) {
      _levelFlashRemaining = 1.2;
    }
    progressChanges.value++;
    return result;
  }

  double recover(double dt) {
    if (dt <= 0 || hp.value >= maxHp || progress.fullness <= 0) {
      return 0;
    }
    const fullnessPerSecond = 5.0;
    const hpPerSecond = 8.0;
    final hpGap = maxHp - hp.value;
    final fullnessForHpGap = hpGap * fullnessPerSecond / hpPerSecond;
    final requestedFullness = math.min(
      fullnessPerSecond * dt,
      fullnessForHpGap,
    );
    final consumed = progress.consumeFullness(requestedFullness);
    final recovered = consumed * hpPerSecond / fullnessPerSecond;
    hp.value = (hp.value + recovered).clamp(0, maxHp);
    progressChanges.value++;
    return recovered;
  }

  void setRecovering(bool value) {
    _isRecovering = value;
  }

  void reviveAt(Vector2 safePosition) {
    hp.value = maxHp;
    position.setFrom(safePosition);
    movement.velocity.setZero();
    movement.endDrag();
    movement.setBoosting(false);
    _hitFlashRemaining = 0;
  }

  @override
  void onRemove() {
    hp.dispose();
    progressChanges.dispose();
    super.onRemove();
  }

  void _constrainToField() {
    final growthScale = gameplaySize / PlayerProgress.baseSize;
    final halfWidth = size.x * growthScale / 2;
    final halfHeight = size.y * growthScale / 2;
    final minX = fieldBounds.left + halfWidth;
    final maxX = fieldBounds.right - halfWidth;
    final minY = fieldBounds.top + halfHeight;
    final maxY = fieldBounds.bottom - halfHeight;

    if (position.x < minX) {
      position.x = minX;
      movement.stopHorizontal();
    } else if (position.x > maxX) {
      position.x = maxX;
      movement.stopHorizontal();
    }

    if (position.y < minY) {
      position.y = minY;
      movement.stopVertical();
    } else if (position.y > maxY) {
      position.y = maxY;
      movement.stopVertical();
    }
  }

  void _updateFacing(double dt) {
    final velocity = movement.velocity;
    if (velocity.length2 < 9) {
      angle *= math.pow(0.08, dt).toDouble();
      return;
    }

    if (velocity.x.abs() > 4) {
      _facing = velocity.x.sign;
      scale.x = _facing * scale.y;
    }

    final targetAngle = math
        .atan2(velocity.y, velocity.x.abs())
        .clamp(-0.5, 0.5);
    final turnBlend = 1 - math.pow(0.002, dt).toDouble();
    angle += (targetAngle - angle) * turnBlend;
  }

  void _updateGrowthScale() {
    final growthScale = gameplaySize / PlayerProgress.baseSize;
    scale.setValues(_facing * growthScale, growthScale);
  }
}
