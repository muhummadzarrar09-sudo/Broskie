import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class InteractableLore extends PositionComponent
    with HasGameReference<BroskieGame>, CollisionCallbacks {
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
    game.showDialogue(speaker, text);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = size.toRect();
    final terminalPaint = Paint()..color = const Color(0xFF1E88E5);
    final screenPaint = Paint()..color = const Color(0xFF00E5FF);

    canvas.drawRect(rect, terminalPaint);
    canvas.drawRect(const Rect.fromLTWH(4, 4, 24, 24), screenPaint);

    // Terminal blinking cursor / icon
    final textPainter = TextPainter(
      text: const TextSpan(
        text: "i",
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(12, 6));
  }
}
