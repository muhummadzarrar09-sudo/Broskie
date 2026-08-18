import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/audio_manager.dart';

abstract class Enemy extends SpriteAnimationComponent with CollisionCallbacks {
  Enemy({required Vector2 position, required Vector2 size}) : super(position: position, size: size) {
    add(RectangleHitbox());
  }

  double speed = -60;
  bool isDead = false;

  @override
  void update(double dt) {
    if (!isDead) {
      position.x += speed * dt;
    }
    super.update(dt);
  }

  void die() {
    isDead = true;
    BroskieAudio.playStomp();
    removeFromParent();
  }
}

class GrumpyBrick extends Enemy {
  double walkAnim = 0;

  GrumpyBrick({required Vector2 position}) : super(position: position, size: Vector2(32, 32));

  @override
  void update(double dt) {
    super.update(dt);
    walkAnim += dt * 8;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !isDead) {
      final playerBottom = other.position.y + other.size.y;
      final enemyTop = position.y;
      
      if (other.velocity.y > 0 && playerBottom <= enemyTop + 14) {
        other.bounce();
        die();
      } else {
        other.hit();
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    if (animation != null) {
      super.render(canvas);
      return;
    }

    final rect = size.toRect();
    final brickColor = Paint()..color = const Color(0xFFD32F2F);
    final darkOutline = Paint()..color = const Color(0xFF800000)..style = PaintingStyle.stroke..strokeWidth = 2;
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    final mouthPaint = Paint()..color = Colors.black..strokeWidth = 2;

    // Body
    canvas.drawRect(rect, brickColor);
    canvas.drawRect(rect, darkOutline);

    // Angry Brows & Eyes
    canvas.drawRect(const Rect.fromLTWH(6, 8, 7, 7), eyePaint);
    canvas.drawRect(const Rect.fromLTWH(19, 8, 7, 7), eyePaint);

    canvas.drawRect(const Rect.fromLTWH(8, 10, 3, 4), pupilPaint);
    canvas.drawRect(const Rect.fromLTWH(21, 10, 3, 4), pupilPaint);

    // Angry eyebrows angled down
    canvas.drawLine(const Offset(4, 6), const Offset(14, 10), darkOutline);
    canvas.drawLine(const Offset(28, 6), const Offset(18, 10), darkOutline);

    // Grumpy Mouth
    canvas.drawLine(const Offset(10, 22), const Offset(22, 20), mouthPaint);

    // Walking Feet
    double legShift = (walkAnim.toInt() % 2 == 0) ? 3 : -3;
    canvas.drawRect(Rect.fromLTWH(4, 28, 8, 4 + legShift), pupilPaint);
    canvas.drawRect(Rect.fromLTWH(20, 28, 8, 4 - legShift), pupilPaint);
  }
}
