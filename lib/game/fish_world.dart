import 'dart:ui';

import 'package:fish_growth_rpg/game/components/ocean_backdrop.dart';
import 'package:fish_growth_rpg/game/components/pixel_fish_component.dart';
import 'package:flame/components.dart';

class FishWorld extends World {
  FishWorld()
    : player = PixelFishComponent(
        position: Vector2.zero(),
        bodyColor: const Color(0xFF38E8D0),
        isPlayer: true,
      );

  final PixelFishComponent player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await addAll([
      OceanBackdrop(),
      player,
      PixelFishComponent(
        position: Vector2(-90, -120),
        bodyColor: const Color(0xFFFFD166),
        scaleFactor: 0.75,
      ),
      PixelFishComponent(
        position: Vector2(100, 80),
        bodyColor: const Color(0xFFFF7B9C),
        scaleFactor: 1.15,
      ),
      PixelFishComponent(
        position: Vector2(-120, 180),
        bodyColor: const Color(0xFF8F9CFF),
        scaleFactor: 1.4,
      ),
    ]);
  }
}
