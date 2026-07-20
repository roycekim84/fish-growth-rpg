import 'dart:ui';

import 'package:flame/components.dart';

class QuestNpcComponent extends PositionComponent {
  QuestNpcComponent({required super.position})
    : super(size: Vector2.all(42), anchor: Anchor.center, priority: 4);

  @override
  void render(Canvas canvas) {
    final shell = Paint()..color = const Color(0xFFFFD166);
    final shadow = Paint()..color = const Color(0xFF7A3E66);
    final glow = Paint()
      ..color = const Color(0xAAFFF0B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2 + 4), 14, shadow);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 12, shell);
    canvas.drawRect(Rect.fromLTWH(19, 8, 4, 25), shadow);
    canvas.drawRect(Rect.fromLTWH(10, 20, 22, 4), shadow);
    canvas.drawRect(
      Rect.fromLTWH(18, 0, 6, 6),
      Paint()..color = const Color(0xFFB8FFF1),
    );
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 18, glow);
  }
}
