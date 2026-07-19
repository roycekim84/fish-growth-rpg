import 'package:fish_growth_rpg/game/controllers/player_movement_controller.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerMovementController', () {
    test('accelerates in the drag direction', () {
      final movement = PlayerMovementController();

      movement.beginDrag(Vector2.zero());
      movement.updateDrag(Vector2(100, 0));
      movement.update(0.1);

      expect(movement.velocity.x, greaterThan(0));
      expect(movement.velocity.y.abs(), lessThan(0.001));
    });

    test('keeps inertia and slows after releasing the drag', () {
      final movement = PlayerMovementController();
      movement.beginDrag(Vector2.zero());
      movement.updateDrag(Vector2(100, 0));
      for (var i = 0; i < 20; i++) {
        movement.update(1 / 60);
      }
      final speedBeforeRelease = movement.velocity.length;

      movement.endDrag();
      movement.update(0.1);

      expect(movement.velocity.length, greaterThan(0));
      expect(movement.velocity.length, lessThan(speedBeforeRelease));
    });

    test('uses a higher speed limit while boosting', () {
      final movement = PlayerMovementController(
        acceleration: 1000,
        maxSpeed: 100,
        boostMultiplier: 1.5,
      );
      movement.beginDrag(Vector2.zero());
      movement.updateDrag(Vector2(100, 0));

      for (var i = 0; i < 120; i++) {
        movement.update(1 / 60);
      }
      expect(movement.velocity.length, closeTo(100, 0.01));

      movement.setBoosting(true);
      for (var i = 0; i < 120; i++) {
        movement.update(1 / 60);
      }
      expect(movement.velocity.length, closeTo(150, 0.01));
    });

    test('ignores movement inside the drag dead zone', () {
      final movement = PlayerMovementController(dragDeadZone: 10);

      movement.beginDrag(Vector2.zero());
      movement.updateDrag(Vector2(5, 5));
      movement.update(0.1);

      expect(movement.velocity, Vector2.zero());
    });

    test('limits automatic steering to 75 percent speed', () {
      final movement = PlayerMovementController(
        acceleration: 1000,
        maxSpeed: 100,
      );
      movement.setAutomaticSteering(Vector2(1, 0));

      for (var i = 0; i < 120; i++) {
        movement.update(1 / 60);
      }

      expect(movement.isAutomaticSteering, isTrue);
      expect(movement.velocity.length, closeTo(75, 0.01));
    });

    test('manual drag immediately clears automatic steering', () {
      final movement = PlayerMovementController();
      movement.setAutomaticSteering(Vector2(1, 0));

      movement.beginDrag(Vector2.zero());
      movement.updateDrag(Vector2(0, 100));
      movement.update(1 / 60);

      expect(movement.isAutomaticSteering, isFalse);
      expect(movement.velocity.y, greaterThan(0));
    });
  });
}
