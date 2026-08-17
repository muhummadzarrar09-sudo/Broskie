import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:broskie_game/game/player.dart';

class RhythmTicker extends SpriteComponent with HasGameRef, CollisionCallbacks {
  double fallSpeed = 100;
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

    // Scale difficulty over time
    bpmScale = 1.0 + (timer / 60.0); // Increases every minute

    if (isFalling) {
      position.y += fallSpeed * bpmScale * dt;
    } else {
      // Logic to trigger fall based on 'Rhythm'
      if (timer % (2.0 / bpmScale) < 0.1) {
        isFalling = true;
      }
    }

    // Reset if off-screen
    if (position.y > 600) {
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
}
