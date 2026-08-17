import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:broskie_game/game/player.dart';

class LevelExit extends PositionComponent with CollisionCallbacks {
  LevelExit({required Vector2 position}) : super(position: position, size: Vector2(64, 128)) {
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      // Trigger Level Complete Logic
      print("Level Complete! Hell Naaaa, we out!");
    }
    super.onCollision(intersectionPoints, other);
  }
}
