import 'dart:math';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// Moving Platform (Horizontal or Vertical)
class MovingPlatform extends PositionComponent
    with HasGameReference<BroskieGame>, CollisionCallbacks {
  final Vector2 startPos;
  final Vector2 targetPos;
  final double speed;
  double progress = 0;
  int direction = 1;
  final Vector2 movement = Vector2.zero();

  MovingPlatform({
    required Vector2 position,
    required Vector2 size,
    required this.targetPos,
    this.speed = 100,
  })  : startPos = position.clone(),
        super(position: position, size: size) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    final prevX = position.x;
    final prevY = position.y;
    double distance = (targetPos - startPos).length;
    if (distance < 1) return;
    progress += direction * (speed * dt) / distance;

    if (progress >= 1.0) {
      progress = 1.0;
      direction = -1;
    } else if (progress <= 0.0) {
      progress = 0.0;
      direction = 1;
    }

    position = Vector2(
      startPos.x + (targetPos.x - startPos.x) * progress,
      startPos.y + (targetPos.y - startPos.y) * progress,
    );
    movement.setValues(position.x - prevX, position.y - prevY);

    // Carry whoever is standing on us. This is what makes a platform a platform.
    final rider = game.player;
    if (rider.riding == this) {
      rider.position.add(movement);
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    canvas.drawRect(rect, Paint()..color = const Color(0xFF3A3428));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 4),
        Paint()..color = const Color(0xFFF2E6D4));
    canvas.drawRect(
        rect,
        Paint()
          ..color = const Color(0xFFFFB800)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }
}

class LaserHazard extends PositionComponent
    with HasGameReference<BroskieGame>, CollisionCallbacks {
  bool isActive = true;
  double pulseTimer = 0;
  final Random _rng = Random();

  LaserHazard({required Vector2 position, required Vector2 size})
      : super(position: position, size: size) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    pulseTimer += dt;
    // Pulse on/off every 2 seconds
    isActive = (pulseTimer % 3.0) < 2.0;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && isActive) {
      other.hit();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) return;

    final rect = size.toRect();
    canvas.drawRect(
        rect, Paint()..color = Colors.redAccent.withValues(alpha: 0.8));
    canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    // Sparkling electrical particles
    for (int i = 0; i < 5; i++) {
      double py = _rng.nextDouble() * size.y;
      canvas.drawCircle(
          Offset(size.x / 2, py), 2, Paint()..color = Colors.yellowAccent);
    }
  }
}

// Data Spikes Hazard
class DataSpike extends PositionComponent
    with HasGameReference<BroskieGame>, CollisionCallbacks {
  DataSpike({required Vector2 position, required Vector2 size})
      : super(position: position, size: size) {
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      other.hit();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    final spikePaint = Paint()..color = const Color(0xFFFF1744);
    double spikeWidth = 16;
    int spikeCount = (size.x / spikeWidth).floor();

    for (int i = 0; i < spikeCount; i++) {
      Path path = Path();
      path.moveTo(i * spikeWidth, size.y);
      path.lineTo(i * spikeWidth + spikeWidth / 2, 0);
      path.lineTo((i + 1) * spikeWidth, size.y);
      path.close();
      canvas.drawPath(path, spikePaint);
    }
  }
}
