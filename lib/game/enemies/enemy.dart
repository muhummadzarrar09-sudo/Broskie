import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:broskie_game/game/player.dart';

abstract class Enemy extends SpriteAnimationComponent with CollisionCallbacks {
  Enemy({required Vector2 position, required Vector2 size}) : super(position: position, size: size) {
    add(RectangleHitbox());
  }

  double speed = -50;
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
    removeFromParent();
  }
}

class GrumpyBrick extends Enemy {
  GrumpyBrick({required Vector2 position}) : super(position: position, size: Vector2(32, 32));

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !isDead) {
      final playerBottom = other.position.y + other.size.y;
      final enemyTop = position.y;
      
      if (other.velocity.y > 0 && playerBottom < enemyTop + 10) {
        other.bounce();
        die();
      } else {
        other.hit();
      }
    }
    super.onCollision(intersectionPoints, other);
  }
}
