import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:broskie_game/game/player.dart';

class WallStreetBull extends SpriteAnimationComponent with CollisionCallbacks {
  bool isCharging = false;
  bool isDizzy = false;
  double patrolSpeed = 50;
  double chargeSpeed = 250;
  int direction = -1; // -1 for Left, 1 for Right

  WallStreetBull({required Vector2 position}) : super(position: position, size: Vector2(64, 48)) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    if (isDizzy) {
      // Don't move
    } else if (isCharging) {
      position.x += direction * chargeSpeed * dt;
    } else {
      position.x += direction * patrolSpeed * dt;
    }
    super.update(dt);
  }

  void startCharge() {
    isCharging = true;
    // Play 'Angry Bull' animation
  }

  void getDizzy() {
    isCharging = false;
    isDizzy = true;
    // Set timer to recover
    Future.delayed(const Duration(seconds: 3), () {
      isDizzy = false;
    });
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      if (isDizzy && other.velocity.y > 0) {
        removeFromParent(); // Stomped!
        other.bounce();
      } else {
        other.hit(); // Ouch!
      }
    }
    super.onCollision(intersectionPoints, other);
  }
}
