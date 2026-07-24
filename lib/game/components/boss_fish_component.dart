import 'dart:math' as math;
import 'dart:ui';

import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:fish_growth_rpg/game/components/npc_fish_component.dart';

class BossFishComponent extends NpcFishComponent {
  BossFishComponent({
    required super.player,
    required super.fieldBounds,
    required super.position,
    required super.onRemoved,
  }) : super(species: definition, random: math.Random(17));

  static const String bossId = 'current_warden';
  static const FishSpecies definition = FishSpecies(
    id: bossId,
    displayName: '해류의 수호자',
    description: '속삭이는 해류의 길을 지키는 고대 물고기',
    behaviorType: 'hunter',
    maxHp: 18,
    strength: 1.5,
    dexterity: 2,
    intelligence: 3,
    speed: 1.35,
    size: 0.7,
    weight: 1,
    expReward: 60,
    fullnessReward: 30,
    unlockEatCount: 999,
    maxSpawnCount: 0,
  );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      Rect.fromLTWH(-3, -8, size.x + 6, size.y + 16),
      Paint()
        ..color = const Color(0xFFBE7BFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (isAlive) {
      final bar = Rect.fromLTWH(-4, -15, size.x + 8, 3);
      canvas.drawRect(bar, Paint()..color = const Color(0xFF07101D));
      canvas.drawRect(
        Rect.fromLTWH(
          bar.left,
          bar.top,
          bar.width * (currentHp / species.maxHp),
          bar.height,
        ),
        Paint()..color = const Color(0xFFBE7BFF),
      );
    }
  }
}
