import 'dart:ui';

import 'package:flame/components.dart';

class UnderwaterLightOverlay extends PositionComponent {
  UnderwaterLightOverlay({required Vector2 logicalSize})
    : super(size: logicalSize, priority: 900);

  double _offset = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _offset = (_offset + dt * 4) % 180;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final lightPaint = Paint()..color = const Color(0x0D8EFFF2);
    for (var x = -180.0 + _offset; x < size.x + 180; x += 180) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + 38, 0)
        ..lineTo(x + 135, size.y)
        ..lineTo(x + 76, size.y)
        ..close();
      canvas.drawPath(path, lightPaint);
    }
  }
}
