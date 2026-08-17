import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:broskie_game/game/player.dart';

enum BossPhase { chilling, mad, berserk }

class TheForeman extends SpriteAnimationComponent with CollisionCallbacks {
  BossPhase phase = BossPhase.chilling;
  int health = 6;
  bool isDizzy = false;
  double speed = 100;
  int direction = -1;
  
  // Timers
  double dazeTimer = 0;
  final double dazeDuration = 8.0;

  TheForeman({required Vector2 position}) : super(position: position, size: Vector2(128, 96)) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    if (isDizzy) {
      dazeTimer -= dt;
      if (dazeTimer <= 0) {
        isDizzy = false;
        speed *= 1.2; // Get faster after daze
      }
    } else {
      position.x += direction * speed * dt;
      
      if (health <= 4 && phase == BossPhase.chilling) {
        phase = BossPhase.mad;
        speed = 200;
        print("Foreman: 'Efficiency is dropping. Initiating aggressive restructuring!'");
      } else if (health <= 2 && phase == BossPhase.mad) {
        _triggerBerserkMode();
      }
    }
    super.update(dt);
  }

  void _triggerBerserkMode() {
    phase = BossPhase.berserk;
    speed *= 3.0;
    print("NEGATIVE SPEED BLITZ ACTIVATED!");
    print("Foreman: 'SYSTEM OVERRIDE! TERMINATE BR-BR-BROSKIE!'");
  }

  void hitByReflectedBrick() {
    if (isDizzy) return;
    health--;
    if (health <= 0) die();
  }

  void crashIntoWall() {
    isDizzy = true;
    dazeTimer = dazeDuration;
    print("Foreman is dazed! 8 second window!");
  }

  void die() {
    print("Foreman: 'System... failure... the Monopoly... will... find... you...'");
    removeFromParent();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      if (isDizzy && other.velocity.y > 0) {
        health -= 2;
        isDizzy = false;
        other.bounce();
      } else {
        other.hit();
      }
    }
    super.onCollision(intersectionPoints, other);
  }
}
