import 'package:fish_growth_rpg/game/components/impact_burst_component.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('combat effects expose distinct timing and particle profiles', () {
    final bite = ImpactBurstComponent(
      position: Vector2.zero(),
      effect: ImpactEffect.bite,
    );
    final consume = ImpactBurstComponent(
      position: Vector2.zero(),
      effect: ImpactEffect.consume,
    );
    final unlock = ImpactBurstComponent(
      position: Vector2.zero(),
      effect: ImpactEffect.unlock,
    );

    expect(bite.duration, lessThan(consume.duration));
    expect(consume.duration, lessThan(unlock.duration));
    expect(ImpactEffect.bite.particleCount, 4);
    expect(ImpactEffect.unlock.particleCount, 12);
    expect(ImpactEffect.hit.color, isNot(ImpactEffect.consume.color));
  });
}
