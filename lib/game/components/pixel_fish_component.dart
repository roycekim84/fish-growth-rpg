import 'dart:ui';

import 'package:flame/components.dart';

class PixelFishComponent extends PositionComponent {
  PixelFishComponent({
    required super.position,
    required this.bodyColor,
    this.scaleFactor = 1,
    this.isPlayer = false,
  }) : super(
         size: Vector2(32 * scaleFactor, 20 * scaleFactor),
         anchor: Anchor.center,
       );

  final Color bodyColor;
  final double scaleFactor;
  final bool isPlayer;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final unit = scaleFactor * 2;
    final dark = Paint()..color = const Color(0xFF071A2D);
    final body = Paint()..color = bodyColor;
    final highlight = Paint()..color = const Color(0xFFB8FFF1);
    final ring = Paint()
      ..color = const Color(0xFF5CFFB1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit;

    if (isPlayer) {
      canvas.drawRect(
        Rect.fromLTWH(unit, unit, size.x - unit * 2, size.y - unit * 2),
        ring,
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(unit * 4, unit * 2, unit * 9, unit * 6),
      body,
    );
    canvas.drawRect(
      Rect.fromLTWH(unit * 2, unit * 3, unit * 3, unit * 4),
      body,
    );
    canvas.drawRect(Rect.fromLTWH(0, unit * 2, unit * 3, unit * 2), body);
    canvas.drawRect(Rect.fromLTWH(0, unit * 6, unit * 3, unit * 2), body);
    canvas.drawRect(
      Rect.fromLTWH(unit * 10, unit * 2, unit * 2, unit),
      highlight,
    );
    canvas.drawRect(Rect.fromLTWH(unit * 12, unit * 4, unit, unit), dark);
  }
}
