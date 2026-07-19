import 'dart:math' as math;
import 'dart:ui';

import 'package:fish_growth_rpg/game/components/pixel_fish_component.dart';
import 'package:fish_growth_rpg/game/controllers/player_movement_controller.dart';

class PlayerFishComponent extends PixelFishComponent {
  PlayerFishComponent({
    required super.position,
    required this.fieldBounds,
    PlayerMovementController? movement,
  }) : movement = movement ?? PlayerMovementController(),
       super(bodyColor: const Color(0xFF38E8D0), isPlayer: true);

  final Rect fieldBounds;
  final PlayerMovementController movement;

  double _facing = 1;

  @override
  void update(double dt) {
    super.update(dt);
    movement.update(dt);
    position.addScaled(movement.velocity, math.min(dt, 1 / 20));
    _constrainToField();
    _updateFacing(dt);
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
