import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/broskie_game.dart';

class LevelExit extends PositionComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  LevelExit({required Vector2 position}) : super(position: position, size: Vector2(64, 128)) {
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      gameRef.triggerLevelComplete();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final portalPaint = Paint()..color = const Color(0xFF00FF66);
    final borderPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3;

    canvas.drawRect(rect, portalPaint.withOpacity(0.8));
    canvas.drawRect(rect, borderPaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: "EXIT\nPORTAL",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}
