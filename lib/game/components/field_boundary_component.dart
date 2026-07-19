import 'dart:ui';

import 'package:flame/components.dart';

class FieldBoundaryComponent extends PositionComponent {
  FieldBoundaryComponent({required Rect bounds})
    : super(
        position: Vector2(bounds.left, bounds.top),
        size: Vector2(bounds.width, bounds.height),
        priority: -80,
      );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final borderPaint = Paint()
      ..color = const Color(0xFF1B6B78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final markerPaint = Paint()..color = const Color(0xFF32D6C4);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), borderPaint);
    for (var x = 16.0; x < size.x - 16; x += 64) {
      canvas.drawRect(Rect.fromLTWH(x, 8, 16, 4), markerPaint);
      canvas.drawRect(Rect.fromLTWH(x, size.y - 12, 16, 4), markerPaint);
    }
    for (var y = 16.0; y < size.y - 16; y += 64) {
      canvas.drawRect(Rect.fromLTWH(8, y, 4, 16), markerPaint);
      canvas.drawRect(Rect.fromLTWH(size.x - 12, y, 4, 16), markerPaint);
    }
  }
}
