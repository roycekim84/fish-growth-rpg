import 'dart:ui';

import 'package:flame/components.dart';

class OceanBackdrop extends PositionComponent {
  OceanBackdrop()
    : super(
        position: Vector2(-720, -960),
        size: Vector2(1440, 1920),
        priority: -100,
      );

  static const double _tileSize = 32;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFF0A3A5A),
    );

    final tilePaint = Paint()..color = const Color(0xFF0D4567);
    for (var y = 0.0; y < size.y; y += _tileSize) {
      for (var x = 0.0; x < size.x; x += _tileSize) {
        if (((x / _tileSize).floor() + (y / _tileSize).floor()).isEven) {
          canvas.drawRect(Rect.fromLTWH(x, y, _tileSize, _tileSize), tilePaint);
        }
      }
    }

    final speckPaint = Paint()..color = const Color(0x5532D6C4);
    for (var y = 20.0; y < size.y; y += 96) {
      final offset = ((y / 96).floor().isEven) ? 12.0 : 52.0;
      for (var x = offset; x < size.x; x += 128) {
        canvas.drawRect(Rect.fromLTWH(x, y, 3, 3), speckPaint);
      }
    }
  }
}
