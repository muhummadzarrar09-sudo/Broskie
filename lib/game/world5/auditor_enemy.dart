import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:broskie_game/game/player.dart';

class AuditorEnemy extends SpriteAnimationComponent with CollisionCallbacks {
  double attackTimer = 0;
  final double attackCooldown = 4.0;

  AuditorEnemy({required Vector2 position}) : super(position: position, size: Vector2(48, 64));

  @override
  void update(double dt) {
    super.update(dt);
    attackTimer += dt;

    if (attackTimer >= attackCooldown) {
      attackTimer = 0;
      _iceSpikeAttack();
    }
  }

  void _iceSpikeAttack() {
    print("Auditor: 'Your assets are FROZEN!' (Aggressive Ice Spike Attack)");
    // Spawns a spike that targets the player's current position
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      // Freeze player logic
      print("PLAYER FROZEN! MASH BUTTONS TO ESCAPE!");
    }
    super.onCollision(intersectionPoints, other);
  }
}
