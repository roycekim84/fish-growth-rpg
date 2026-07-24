import 'dart:math' as math;
import 'dart:ui';

import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:flame/components.dart';

class DeepSeaVentComponent extends PositionComponent {
  DeepSeaVentComponent({
    required super.position,
    required this.player,
    required this.onDamage,
    this.radius = 74,
    this.damagePerSecond = 6,
    this.outwardCurrentStrength = 85,
  }) : super(anchor: Anchor.center, size: Vector2.all(radius * 2), priority: 1);

  final PlayerFishComponent player;
  final void Function(double damage) onDamage;
  final double radius;
  final double damagePerSecond;
  final double outwardCurrentStrength;

  double _pulse = 0;
  double _pendingDamage = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt;
    final offset = player.position - position;
    final distance = offset.length;
    if (distance > radius) {
      _pendingDamage = 0;
      return;
    }
    if (distance > 0.01) {
      final push = offset / distance * outwardCurrentStrength * dt;
      player.movement.velocity.add(push);
    }
    _pendingDamage += damagePerSecond * dt;
    if (_pendingDamage >= 0.35) {
      onDamage(_pendingDamage);
      _pendingDamage = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(size.x / 2, size.y / 2);
    final pulse = 0.78 + math.sin(_pulse * 5) * 0.12;
    final fill = Paint()..color = const Color(0x4437D8FF);
    final line = Paint()
      ..color = const Color(0xFF77F3FF).withValues(alpha: pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(center, radius - 3, line);
    for (var y = size.y - 16.0; y > 10; y -= 12) {
      final sway = math.sin(_pulse * 6 + y) * 5;
      canvas.drawRect(
        Rect.fromLTWH(size.x / 2 + sway - 2, y, 4, 7),
        Paint()..color = const Color(0xFF77F3FF),
      );
    }
  }
}
