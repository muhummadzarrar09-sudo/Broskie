import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/broskie_game.dart';

enum SwarmShape { fist, sword, shield, broskieMirror }

class LordStatic extends PositionComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  SwarmShape currentShape = SwarmShape.shield;
  int health = 20;
  final Random _rng = Random();
  double shapeTimer = 0;

  LordStatic({required Vector2 position}) : super(position: position, size: Vector2(100, 100)) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    shapeTimer += dt;

    if (shapeTimer > 5.0) {
      shapeTimer = 0;
      _changeShape();
    }
  }

  void _changeShape() {
    currentShape = SwarmShape.values[_rng.nextInt(SwarmShape.values.length)];
    print("Lord Static changed shape to: ${currentShape.name}");
    
    if (currentShape == SwarmShape.fist) {
      size = Vector2(150, 150);
    } else if (currentShape == SwarmShape.sword) {
      size = Vector2(50, 250);
    }
  }

  void hit() {
    health--;
    if (health <= 0) {
      _triggerBroskieCorpEnding();
    }
  }

  void _triggerBroskieCorpEnding() {
    print("STORY ENDING: Broskie takes over the Monopoly!");
    print("Broskie: 'Standardization is over. Everyone, find your own beat. Welcome to Broskie Corp.'");
  }
}
