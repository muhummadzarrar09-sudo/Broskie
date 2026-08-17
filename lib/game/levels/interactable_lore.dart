import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:broskie_game/game/player.dart';

class InteractableLore extends SpriteComponent with CollisionCallbacks {
  final String text;
  final String speaker;
  bool _hasTriggered = false;

  InteractableLore({
    required Vector2 position, 
    required this.speaker, 
    required this.text,
  }) : super(position: position, size: Vector2(32, 48)) {
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !_hasTriggered) {
      _hasTriggered = true;
      _showDialogue();
    }
    super.onCollision(intersectionPoints, other);
  }

  void _showDialogue() {
    print("$speaker: $text");
    // This will trigger the DialogueBox UI overlay
  }
}
