import 'dart:math' as math;
import 'dart:ui';

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
  }) : movement = movement ?? PlayerMovementController(),
       super(bodyColor: const Color(0xFF38E8D0), isPlayer: true);

  final Rect fieldBounds;
  final PlayerMovementController movement;
  final ValueNotifier<double> hp = ValueNotifier<double>(40);

  void Function(PositionComponent other)? onContactStart;
  void Function(PositionComponent other)? onContactEnd;

  double get gameplaySize => 0.8;
  double get maxHp => 40;
  double get strength => 3;
  bool get isAlive => hp.value > 0;

  double _facing = 1;
  double _hitFlashRemaining = 0;

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
    movement.update(dt);
    position.addScaled(movement.velocity, math.min(dt, 1 / 20));
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
    super.onRemove();
  }

  void _constrainToField() {
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;
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
      scale.x = _facing;
    }

    final targetAngle = math
        .atan2(velocity.y, velocity.x.abs())
        .clamp(-0.5, 0.5);
    final turnBlend = 1 - math.pow(0.002, dt).toDouble();
    angle += (targetAngle - angle) * turnBlend;
  }
}
