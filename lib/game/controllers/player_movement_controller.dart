import 'dart:math' as math;

import 'package:flame/components.dart';

class PlayerMovementController {
  PlayerMovementController({
    this.acceleration = 360,
    this.maxSpeed = 135,
    this.boostMultiplier = 1.65,
    this.coastingDragPerSecond = 0.16,
    this.steeringDragPerSecond = 0.72,
    this.dragDeadZone = 10,
  });

  final double acceleration;
  final double maxSpeed;
  final double boostMultiplier;
  final double coastingDragPerSecond;
  final double steeringDragPerSecond;
  final double dragDeadZone;

  final Vector2 velocity = Vector2.zero();
  final Vector2 inputDirection = Vector2.zero();
  final Vector2 automaticDirection = Vector2.zero();

  Vector2? _dragAnchor;
  bool _isBoosting = false;
  double _automaticSpeedMultiplier = 0.75;

  bool get isDragging => _dragAnchor != null;
  bool get isBoosting => _isBoosting;
  bool get isAutomaticSteering => !automaticDirection.isZero() && !isDragging;
  double get currentMaxSpeed {
    if (isAutomaticSteering) {
      return maxSpeed * _automaticSpeedMultiplier;
    }
    return maxSpeed * (isBoosting ? boostMultiplier : 1);
  }

  void beginDrag(Vector2 position) {
    if (!position.x.isFinite || !position.y.isFinite) {
      return;
    }
    _dragAnchor = position.clone();
    inputDirection.setZero();
    clearAutomaticSteering();
  }

  void updateDrag(Vector2 position) {
    final anchor = _dragAnchor;
    if (anchor == null || !position.x.isFinite || !position.y.isFinite) {
      return;
    }

    final displacement = position - anchor;
    if (displacement.length <= dragDeadZone) {
      inputDirection.setZero();
      return;
    }

    inputDirection.setFrom(displacement.normalized());
  }

  void endDrag() {
    _dragAnchor = null;
    inputDirection.setZero();
  }

  void setBoosting(bool value) {
    _isBoosting = value;
  }

  void setAutomaticSteering(
    Vector2 direction, {
    double speedMultiplier = 0.75,
  }) {
    if (isDragging || direction.isZero()) {
      clearAutomaticSteering();
      return;
    }
    automaticDirection.setFrom(direction.normalized());
    _automaticSpeedMultiplier = speedMultiplier.clamp(0, 1);
  }

  void clearAutomaticSteering() {
    automaticDirection.setZero();
  }

  void haltAutomaticMovement() {
    clearAutomaticSteering();
    velocity.setZero();
  }

  void update(double deltaTime) {
    if (deltaTime <= 0) {
      return;
    }

    final safeDelta = math.min(deltaTime, 1 / 20);
    final effectiveDirection = isDragging ? inputDirection : automaticDirection;
    if (!effectiveDirection.isZero()) {
      velocity.addScaled(effectiveDirection, acceleration * safeDelta);
      _applyExponentialDrag(steeringDragPerSecond, safeDelta);
    } else {
      _applyExponentialDrag(coastingDragPerSecond, safeDelta);
    }

    final speedLimit = currentMaxSpeed;
    if (velocity.length2 > speedLimit * speedLimit) {
      velocity.scale(speedLimit / velocity.length);
    }

    if (velocity.length2 < 0.01) {
      velocity.setZero();
    }
  }

  void stopHorizontal() {
    velocity.x = 0;
  }

  void stopVertical() {
    velocity.y = 0;
  }

  void _applyExponentialDrag(double retainedPerSecond, double deltaTime) {
    velocity.scale(math.pow(retainedPerSecond, deltaTime).toDouble());
  }
}
