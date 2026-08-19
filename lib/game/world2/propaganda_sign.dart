import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PropagandaSign extends SpriteComponent
    with HasGameReference<BroskieGame> {
  bool isHacked = false;

  PropagandaSign({required Vector2 position})
      : super(position: position, size: Vector2(80, 40));

  @override
  void update(double dt) {
    super.update(dt);

    final player = game.children.whereType<Player>().firstOrNull;
    if (player != null && player.position.x > position.x - 150) {
      if (!isHacked) {
        isHacked = true;
        game.showDialogue(
            "CYBER SIGN", "WELCOME TO NEO-CITY -> OBEY & STANDARDIZE!");
      }
    }
  }

  @override
  // ignore: must_call_super — we paint the whole sprite ourselves
  void render(Canvas canvas) {
    final rect = size.toRect();
    // Propaganda flickers on the stage beat — even the ads dance.
    final pulse = 0.65 + 0.35 * game.beatPulse;
    final bgPaint = Paint()
      ..color = (isHacked ? const Color(0xFFD50000) : const Color(0xFF00E5FF))
          .withValues(alpha: pulse);

    canvas.drawRect(rect, bgPaint);
    canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);

    final textPainter = TextPainter(
      text: TextSpan(
        text: isHacked ? "OBEY!" : "WELCOME",
        style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset((size.x - textPainter.width) / 2,
            (size.y - textPainter.height) / 2 - 4));

    // Every corporate ad carries its own barcode — product goes out the door.
    drawBarcode(canvas, const Rect.fromLTWH(8, 30, 26, 8),
        seed: 11, color: Colors.black87);
  }
}
