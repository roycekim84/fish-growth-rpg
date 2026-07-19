import 'dart:ui';

import 'package:fish_growth_rpg/domain/models/player_progress.dart';
import 'package:fish_growth_rpg/game/components/player_fish_component.dart';
import 'package:fish_growth_rpg/game/systems/recovery_system.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recovers after 1.5 idle seconds using fullness', () {
    final player = _player();
    player.takeDamage(20);
    var starts = 0;
    final recovery = RecoverySystem(
      player: player,
      onRecoveryStarted: () => starts++,
    );

    for (var i = 0; i < 14; i++) {
      recovery.update(0.1);
    }
    expect(player.hp.value, 20);
    expect(recovery.isRecovering.value, isFalse);

    recovery.update(0.1);

    expect(player.hp.value, closeTo(20.8, 0.001));
    expect(player.progress.fullness, closeTo(49.5, 0.001));
    expect(recovery.isRecovering.value, isTrue);
    expect(starts, 1);
  });

  test('waits for combat cooldown and stops for movement input', () {
    final player = _player();
    final recovery = RecoverySystem(player: player, onRecoveryStarted: () {});

    for (var i = 0; i < 15; i++) {
      recovery.update(0.1);
    }
    player.takeDamage(10);
    recovery.markCombat();
    for (var i = 0; i < 9; i++) {
      recovery.update(0.1);
    }
    expect(player.hp.value, 30);

    recovery.update(0.2);
    expect(player.hp.value, greaterThan(30));

    player.movement.beginDrag(Vector2.zero());
    player.movement.updateDrag(Vector2(100, 0));
    recovery.update(0.1);
    expect(recovery.isRecovering.value, isFalse);
    expect(recovery.idleDuration, 0);
  });

  test('scales HP recovery to the last unit of fullness', () {
    final player = _player(fullness: 1);
    player.takeDamage(10);

    final recovered = player.recover(1);

    expect(recovered, closeTo(1.6, 0.001));
    expect(player.hp.value, closeTo(31.6, 0.001));
    expect(player.progress.fullness, 0);
  });

  test('exposes the one second combat lock for species change', () {
    final player = _player();
    final recovery = RecoverySystem(player: player, onRecoveryStarted: () {});

    recovery.markCombat();
    expect(recovery.isCombatLocked, isTrue);

    recovery.update(1.01);
    expect(recovery.isCombatLocked, isFalse);
  });
}

PlayerFishComponent _player({double fullness = 50}) {
  return PlayerFishComponent(
    position: Vector2.zero(),
    fieldBounds: const Rect.fromLTRB(-100, -100, 100, 100),
    progress: PlayerProgress(fullness: fullness),
  );
}
