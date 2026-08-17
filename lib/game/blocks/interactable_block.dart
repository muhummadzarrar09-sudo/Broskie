import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:broskie_game/game/player.dart';

enum BlockType { brick, mystery, solid }

class InteractableBlock extends SpriteComponent with CollisionCallbacks {
  final BlockType type;
  bool isHit = false;

  InteractableBlock({required Vector2 position, required this.type}) 
    : super(position: position, size: Vector2(32, 32)) {
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !isHit) {
      if (other.velocity.y < 0 && other.position.y > (position.y + size.y - 10)) {
        triggerBlock(other);
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  void triggerBlock(Player player) {
    if (type == BlockType.brick) {
      if (player.isBig) {
        removeFromParent(); // Smash!
      } else {
        _bounceEffect();
      }
    } else if (type == BlockType.mystery) {
      isHit = true;
      _spawnItem(player);
      _bounceEffect();
    }
  }

  void _bounceEffect() {
    final originalY = position.y;
    position.y -= 5;
    Future.delayed(const Duration(milliseconds: 100), () {
      position.y = originalY;
    });
  }

  void _spawnItem(Player player) {
    // Randomly pick a drink variant for more variability
    final variants = [PowerUpType.classic, PowerUpType.juggernaut, PowerUpType.shockwave];
    final selected = (variants..shuffle()).first;
    
    player.grow(selected);
    
    String message = "GOD DAYUM! ";
    if (selected == PowerUpType.juggernaut) message += "JUGGERNAUT COLA!";
    if (selected == PowerUpType.shockwave) message += "SHOCKWAVE SODA!";
    if (selected == PowerUpType.classic) message += "VOLT-COLA!";
    
    print(message);
  }
}
