import 'dart:ui';

import 'package:fish_growth_rpg/game/controllers/player_movement_controller.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class DragInputSurface extends PositionComponent with DragCallbacks {
  DragInputSurface({required this.movement, required Vector2 logicalSize})
    : super(size: logicalSize, priority: 1000);

  final PlayerMovementController movement;

  Vector2? _dragAnchor;
  Vector2? _dragPosition;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragAnchor = event.localPosition.clone();
    _dragPosition = event.localPosition.clone();
    movement.beginDrag(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _dragPosition = event.localEndPosition.clone();
    movement.updateDrag(event.localEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _clearDrag();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _clearDrag();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final anchor = _dragAnchor;
    final current = _dragPosition;
    if (anchor == null || current == null) {
      return;
    }

    final linePaint = Paint()
      ..color = const Color(0x8832D6C4)
      ..strokeWidth = 2;
    final fillPaint = Paint()..color = const Color(0x4432D6C4);
    final borderPaint = Paint()
      ..color = const Color(0xCCB8FFF1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(anchor.toOffset(), current.toOffset(), linePaint);
    canvas.drawCircle(anchor.toOffset(), 18, fillPaint);
    canvas.drawCircle(anchor.toOffset(), 18, borderPaint);
    canvas.drawCircle(current.toOffset(), 8, fillPaint);
    canvas.drawCircle(current.toOffset(), 8, borderPaint);
  }

  void _clearDrag() {
    movement.endDrag();
    _dragAnchor = null;
    _dragPosition = null;
  }
}
