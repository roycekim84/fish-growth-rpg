import 'dart:ui';

import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:flame/components.dart';

class RegionGateComponent extends PositionComponent {
  RegionGateComponent({
    required Rect bounds,
    required this.player,
    required this.isUnlocked,
    required this.onBlocked,
    this.onEnter,
  }) : super(
         position: Vector2(bounds.left, bounds.top),
         size: Vector2(bounds.width, bounds.height),
         priority: 2,
       );

  final PlayerFishComponent player;
  final bool Function() isUnlocked;
  final VoidCallback onBlocked;
  final VoidCallback? onEnter;
  double _messageCooldown = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _messageCooldown -= dt;
    if (!containsPoint(player.position)) {
      return;
    }
    if (isUnlocked()) {
      if (_messageCooldown <= 0) {
        onEnter?.call();
        _messageCooldown = 1.2;
      }
      return;
    }
    player.position.y = position.y + size.y + 3;
    player.movement.velocity.setZero();
    if (_messageCooldown <= 0) {
      onBlocked();
      _messageCooldown = 1.2;
    }
  }

  @override
  void render(Canvas canvas) {
    final open = isUnlocked();
    final color = open ? const Color(0xFF5CFFB1) : const Color(0xFFBE7BFF);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = color.withValues(alpha: 0.28),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}
