import 'dart:ui';

import 'package:flame/components.dart';

class ImpactBurstComponent extends PositionComponent {
  ImpactBurstComponent({required super.position, required this.color})
    : super(anchor: Anchor.center, priority: 200);

  final Color color;
  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= 0.32) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_elapsed / 0.32).clamp(0.0, 1.0);
    final distance = 5 + progress * 15;
    final pixelSize = 4 - progress * 2;
    final paint = Paint()..color = color.withValues(alpha: 1 - progress);
    for (var i = 0; i < 8; i++) {
      final dx = switch (i) {
        0 || 1 || 7 => distance,
        3 || 4 || 5 => -distance,
        _ => 0.0,
      };
      final dy = switch (i) {
        1 || 2 || 3 => distance,
        5 || 6 || 7 => -distance,
        _ => 0.0,
      };
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(dx, dy),
          width: pixelSize,
          height: pixelSize,
        ),
        paint,
      );
    }
  }
}
