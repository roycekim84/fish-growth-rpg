import 'dart:ui';

import 'package:fish_growth_rpg/game/components/pixel_fish_component.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defines a four-frame runtime strip for every playable species', () {
    expect(
      PixelFishComponent.spriteStrips.keys,
      containsAll(<String>[
        'starter_fish',
        'small_fish',
        'puffer_fish',
        'hunter_fish',
      ]),
    );
    expect(
      PixelFishComponent.spriteStrips.values.every(
        (strip) => strip.frameCount == 4,
      ),
      isTrue,
    );
  });

  test('advances and loops the swim animation without loading an asset', () async {
    final fish = PixelFishComponent(
      position: Vector2.zero(),
      bodyColor: const Color(0xFFFFFFFF),
      speciesId: 'small_fish',
    );
    await fish.setSpeciesVisual('small_fish');

    fish.update(0.15);
    expect(fish.animationFrame, 1);

    fish.update(0.42);
    expect(fish.animationFrame, 0);
  });
}
