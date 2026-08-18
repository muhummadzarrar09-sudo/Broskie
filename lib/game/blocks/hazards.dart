import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/broskie_game.dart';

// Moving Platform (Horizontal or Vertical)
class MovingPlatform extends PositionComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  final Vector2 startPos;
  final Vector2 targetPos;
  final double speed;
  double progress = 0;
  int direction = 1;

  MovingPlatform({
    required Vector2 position,
    required Vector2 size,
    required this.targetPos,
    this.speed = 100,
  }) : startPos = position.clone(), super(position: position, size: size) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    double distance = (targetPos - startPos).length;
    progress += direction * (speed * dt) / distance;

    if (progress >= 1.0) {
      progress = 1.0;
      direction = -1;
    } else if (progress <= 0.0) {
      progress = 0.0;
      direction = 1;
    }

    position = Vector2.zero()..setFrom(startPos).lerp(targetPos, progress);
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    canvas.drawRect(rect, Paint()..color = const Color(0xFF00E5FF)); // Cyan Moving Platform
    canvas.drawRect(rect, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
  }
}

// Crumbling Platform (Collapses 1s after player steps on it)
class CrumblingPlatform extends PositionComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  bool isStepped = false;
  double timer = 0;

  CrumblingPlatform({required Vector2 position, required Vector2 size}) : super(position: position, size: size) {
    add(RectangleHitbox());
  }

  void stepOn() {
    if (!isStepped) {
      isStepped = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isStepped) {
      timer += dt;
      if (timer >= 0.8) {
        removeFromParent(); // Collapse platform!
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final color = isStepped ? Colors.orangeAccent : const Color(0xFF795548);
    canvas.drawRect(rect, Paint()..color = color);
    canvas.drawRect(rect, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);

    if (isStepped) {
      // Crack lines
      canvas.drawLine(const Offset(4, 0), Offset(size.x - 4, size.y), Paint()..color = Colors.black..strokeWidth = 2);
    }
  }
}

// Laser Hazard (Pulsing deadly laser barrier)
class LaserHazard extends PositionComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  bool isActive = true;
  double pulseTimer = 0;

  LaserHazard({required Vector2 position, required Vector2 size}) : super(position: position, size: size) {
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
    canvas.drawRect(rect, Paint()..color = Colors.redAccent.withOpacity(0.8));
    canvas.drawRect(rect, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Sparkling electrical particles
    for (int i = 0; i < 5; i++) {
      double py = Random().nextDouble() * size.y;
      canvas.drawCircle(Offset(size.x / 2, py), 2, Paint()..color = Colors.yellowAccent);
    }
  }
}

// Data Spikes Hazard
class DataSpike extends PositionComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  DataSpike({required Vector2 position, required Vector2 size}) : super(position: position, size: size) {
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
