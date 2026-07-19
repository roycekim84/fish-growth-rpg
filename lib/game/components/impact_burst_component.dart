import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/components.dart';

class ImpactBurstComponent extends PositionComponent {
  ImpactBurstComponent({
    required super.position,
    required this.effect,
    Color? color,
  }) : color = color ?? effect.color,
       super(anchor: Anchor.center, priority: 200);

  final ImpactEffect effect;
  final Color color;
  double _elapsed = 0;

  double get duration => effect.duration;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final distance = effect.startDistance + progress * effect.travelDistance;
    final pixelSize = effect.pixelSize * (1 - progress * 0.55);
    final paint = Paint()..color = color.withValues(alpha: 1 - progress);
    final count = effect.particleCount;
    final rise =
        effect == ImpactEffect.levelUp || effect == ImpactEffect.unlock;
    for (var i = 0; i < count; i++) {
      final angle = math.pi * 2 * i / count;
      final dx = math.cos(angle) * distance;
      final dy = math.sin(angle) * distance - (rise ? progress * 18 : 0);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(dx, dy),
          width: pixelSize,
          height: pixelSize,
        ),
        paint,
      );
    }
    if (effect == ImpactEffect.bite && progress < 0.6) {
      final toothPaint = Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 1 - progress);
      canvas.drawRect(Rect.fromLTWH(-8, -7 + progress * 4, 5, 4), toothPaint);
      canvas.drawRect(Rect.fromLTWH(3, 3 - progress * 4, 5, 4), toothPaint);
    }
  }
}

enum ImpactEffect {
  bite(
    color: Color(0xFFFFE9A8),
    duration: 0.20,
    particleCount: 4,
    pixelSize: 4,
    startDistance: 2,
    travelDistance: 10,
  ),
  hit(
    color: Color(0xFFFF5C72),
    duration: 0.30,
    particleCount: 8,
    pixelSize: 4,
    startDistance: 5,
    travelDistance: 15,
  ),
  consume(
    color: Color(0xFF5CFFB1),
    duration: 0.42,
    particleCount: 8,
    pixelSize: 4,
    startDistance: 4,
    travelDistance: 18,
  ),
  levelUp(
    color: Color(0xFFFFD166),
    duration: 0.68,
    particleCount: 10,
    pixelSize: 5,
    startDistance: 8,
    travelDistance: 22,
  ),
  unlock(
    color: Color(0xFFC58CFF),
    duration: 0.76,
    particleCount: 12,
    pixelSize: 5,
    startDistance: 9,
    travelDistance: 25,
  );

  const ImpactEffect({
    required this.color,
    required this.duration,
    required this.particleCount,
    required this.pixelSize,
    required this.startDistance,
    required this.travelDistance,
  });

  final Color color;
  final double duration;
  final int particleCount;
  final double pixelSize;
  final double startDistance;
  final double travelDistance;
}
