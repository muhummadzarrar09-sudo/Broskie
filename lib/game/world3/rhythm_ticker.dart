import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/player.dart';

class RhythmTicker extends SpriteComponent with CollisionCallbacks {
  double fallSpeed = 120;
  double bpmScale = 1.0;
  bool isFalling = false;
  double timer = 0;

  RhythmTicker({required Vector2 position}) : super(position: position, size: Vector2(48, 48)) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer += dt;

    bpmScale = 1.0 + (timer / 60.0);

    if (isFalling) {
      position.y += fallSpeed * bpmScale * dt;
    } else {
      if (timer % (2.0 / bpmScale) < 0.1) {
        isFalling = true;
      }
    }

    if (position.y > 700) {
      removeFromParent();
    }
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
    final rect = size.toRect();
    canvas.drawRect(rect, Paint()..color = const Color(0xFFFFD700)); // Gold ticker
    canvas.drawRect(rect, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);
  }
}
