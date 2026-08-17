import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/broskie_game.dart';

class VinylBoomerang extends SpriteComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  final double speed = 400;
  bool returning = false;
  late Vector2 direction;
  late Player owner;

  VinylBoomerang({required Vector2 position, required this.owner, required bool isLeft}) 
    : super(position: position, size: Vector2(24, 24)) {
    direction = isLeft ? Vector2(-1, 0) : Vector2(1, 0);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!returning) {
      position += direction * speed * dt;
      if ((position - owner.position).length > 300) {
        returning = true;
      }
    } else {
      Vector2 toPlayer = (owner.position - position).normalized();
      position += toPlayer * speed * dt;
      
      if ((position - owner.position).length < 20) {
        removeFromParent();
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && returning) {
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}
