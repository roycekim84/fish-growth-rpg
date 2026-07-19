import 'dart:math' as math;
import 'dart:ui';

import 'package:fish_growth_rpg/domain/models/fish_species.dart';
import 'package:fish_growth_rpg/game/components/pixel_fish_component.dart';
import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:fish_growth_rpg/game/controllers/npc_ai_controller.dart';
import 'package:flame/components.dart';

class NpcFishComponent extends PixelFishComponent {
  NpcFishComponent({
    required this.species,
    required this.player,
    required this.fieldBounds,
    required super.position,
    required math.Random random,
    required this.onRemoved,
  }) : ai = NpcAiController(
         behaviorType: species.behaviorType,
         npcSize: species.size,
         random: random,
       ),
       super(
         bodyColor: _colorForSpecies(species.id),
         scaleFactor: _visualScaleForSpecies(species.id),
       );

  final FishSpecies species;
  final PlayerFishComponent player;
  final Rect fieldBounds;
  final NpcAiController ai;
  final void Function(NpcFishComponent fish) onRemoved;
  final Vector2 velocity = Vector2.zero();

  bool _reportedRemoval = false;

  double get gameplaySize => species.size;

  @override
  void update(double dt) {
    super.update(dt);
    ai.update(
      deltaTime: dt,
      position: position,
      playerPosition: player.position,
      playerSize: player.gameplaySize,
      fieldBounds: fieldBounds,
    );

    final desiredVelocity = ai.desiredDirection * (species.speed * 55);
    final safeDelta = math.min(dt, 1 / 20);
    final steeringBlend = 1 - math.pow(0.035, safeDelta).toDouble();
    velocity.add((desiredVelocity - velocity)..scale(steeringBlend));
    position.addScaled(velocity, safeDelta);
    _constrainToField();
    _updateFacing(safeDelta);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final stateColor = switch (ai.state) {
      NpcAiState.wander => const Color(0xFFB8FFF1),
      NpcAiState.flee => const Color(0xFF61AFFF),
      NpcAiState.chase => const Color(0xFFFF5C72),
    };
    canvas.drawRect(
      Rect.fromLTWH(size.x / 2 - 2, -5, 4, 3),
      Paint()..color = stateColor,
    );
  }

  @override
  void onRemove() {
    if (!_reportedRemoval) {
      _reportedRemoval = true;
      onRemoved(this);
    }
    super.onRemove();
  }

  void _constrainToField() {
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;
    final minX = fieldBounds.left + halfWidth;
    final maxX = fieldBounds.right - halfWidth;
    final minY = fieldBounds.top + halfHeight;
    final maxY = fieldBounds.bottom - halfHeight;

    if (position.x < minX || position.x > maxX) {
      position.x = position.x.clamp(minX, maxX);
      velocity.x = 0;
    }
    if (position.y < minY || position.y > maxY) {
      position.y = position.y.clamp(minY, maxY);
      velocity.y = 0;
    }
  }

  void _updateFacing(double dt) {
    if (velocity.length2 < 4) {
      return;
    }
    if (velocity.x.abs() > 2) {
      scale.x = velocity.x.sign;
    }
    final targetAngle = math
        .atan2(velocity.y, velocity.x.abs())
        .clamp(-0.45, 0.45);
    final blend = 1 - math.pow(0.015, dt).toDouble();
    angle += (targetAngle - angle) * blend;
  }

  static Color _colorForSpecies(String id) {
    return switch (id) {
      'small_fish' => const Color(0xFFFFD166),
      'puffer_fish' => const Color(0xFFFF7B9C),
      'hunter_fish' => const Color(0xFF8F9CFF),
      _ => const Color(0xFFB8FFF1),
    };
  }

  static double _visualScaleForSpecies(String id) {
    return switch (id) {
      'small_fish' => 0.75,
      'puffer_fish' => 1.15,
      'hunter_fish' => 1.4,
      _ => 1,
    };
  }
}
