import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:broskie_game/game/player.dart';

enum DebuffType { slow, lowJump, invertedControls, noDash }

class HaterCloud extends SpriteComponent with HasGameRef, CollisionCallbacks {
  double timer = 0;
  final double attackInterval = 3.0;

  HaterCloud({required Vector2 position}) : super(position: position, size: Vector2(64, 48));

  @override
  void update(double dt) {
    super.update(dt);
    timer += dt;

    if (timer >= attackInterval) {
      timer = 0;
      _performRandomAttack();
    }
    
    // Hover movement
    position.x += (DateTime.now().millisecondsSinceEpoch % 2000 > 1000 ? 1 : -1) * 20 * dt;
  }

  void _performRandomAttack() {
    // 1. Spiky Comment (Spawns a projectile)
    // 2. Data-Wind (Applies force to player)
    // 3. Buffer Rain (Slows player)
    print("Hater Cloud: 'L + Ratio + Get Standardized!' (Attack Triggered)");
  }
}

class Debuff {
  final DebuffType type;
  double duration;

  Debuff(this.type, this.duration);
}
