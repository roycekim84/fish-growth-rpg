import 'dart:ui';

import 'package:flame/components.dart';

class BossArenaBoundaryComponent extends PositionComponent {
  BossArenaBoundaryComponent({required Rect bounds})
    : super(
        position: Vector2(bounds.left, bounds.top),
        size: Vector2(bounds.width, bounds.height),
        priority: 1,
      );

  @override
  void render(Canvas canvas) {
    final border = Paint()
      ..color = const Color(0xFFBE7BFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), border);
    for (var x = 14.0; x < size.x - 14; x += 44) {
      canvas.drawRect(
        Rect.fromLTWH(x, 6, 12, 3),
        Paint()..color = const Color(0xFFBE7BFF),
      );
    }
  }
}
