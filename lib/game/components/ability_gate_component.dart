import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

class AbilityGateComponent extends PositionComponent {
  AbilityGateComponent({
    required Rect bounds,
    required this.player,
    required this.requiredAbilityId,
    required this.label,
    required this.onBlocked,
  }) : super(
         position: Vector2(bounds.left, bounds.top),
         size: Vector2(bounds.width, bounds.height),
         priority: 2,
       );

  final PlayerFishComponent player;
  final String requiredAbilityId;
  final String label;
  final void Function(String label) onBlocked;

  double _messageCooldown = 0;

  bool get isUnlocked => player.currentAbilityId == requiredAbilityId;

  @override
  void update(double dt) {
    super.update(dt);
    _messageCooldown -= dt;
    if (isUnlocked || !containsPoint(player.position)) {
      return;
    }
    final local = player.position - position;
    final distances = <double>[
      local.x,
      size.x - local.x,
      local.y,
      size.y - local.y,
    ];
    var nearestIndex = 0;
    for (var index = 1; index < distances.length; index++) {
      if (distances[index] < distances[nearestIndex]) {
        nearestIndex = index;
      }
    }
    switch (nearestIndex) {
      case 0:
        player.position.x = position.x - 2;
      case 1:
        player.position.x = position.x + size.x + 2;
      case 2:
        player.position.y = position.y - 2;
      case 3:
        player.position.y = position.y + size.y + 2;
    }
    player.movement.velocity.setZero();
    if (_messageCooldown <= 0) {
      onBlocked(label);
      _messageCooldown = 1.2;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final color = isUnlocked
        ? const Color(0xFF5CFFB1)
        : const Color(0xFFFF7B9C);
    final fill = Paint()..color = color.withValues(alpha: 0.18);
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), fill);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), line);
    for (var x = 4.0; x < size.x; x += 12) {
      canvas.drawLine(Offset(x, 0), Offset(x - 8, size.y), line);
    }
    final text = TextPainter(
      text: TextSpan(
        text: isUnlocked ? 'OPEN' : 'LOCK',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(
      canvas,
      Offset((size.x - text.width) / 2, (size.y - text.height) / 2),
    );
  }
}
