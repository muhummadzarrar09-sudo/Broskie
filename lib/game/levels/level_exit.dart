import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LevelExit extends PositionComponent
    with HasGameReference<BroskieGame>, CollisionCallbacks {
  /// When provided, the portal stays locked while this returns true
  /// (e.g. Stage 4: both executives must be defeated first).
  final bool Function()? lockCondition;
  final String lockHint;

  bool locked = false;
  double _pollTimer = 0.2; // evaluate immediately on first update
  double _hintCooldown = 0;

  LevelExit(
      {required Vector2 position, this.lockCondition, this.lockHint = 'LOCKED'})
      : super(position: position, size: Vector2(64, 128)) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_hintCooldown > 0) _hintCooldown -= dt;
    final condition = lockCondition;
    if (condition != null) {
      _pollTimer += dt;
      if (_pollTimer >= 0.2) {
        _pollTimer = 0;
        locked = condition();
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      if (locked) {
        if (_hintCooldown <= 0) {
          _hintCooldown = 3.0;
          game.showDialogue("EXIT GATE", lockHint);
        }
      } else {
        game.triggerLevelComplete();
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final portalPaint = Paint()
      ..color = locked ? Colors.redAccent : const Color(0xFF00FF66);
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Unlocked portals thump on the beat — the door IS the drop.
    final glow = locked ? 0.45 : 0.55 + 0.45 * game.beatPulse;
    canvas.drawRect(
        rect, Paint()..color = portalPaint.color.withValues(alpha: glow));
    canvas.drawRect(rect, borderPaint);

    // Locked portals carry the corporate seal: a barcode customs strip.
    // The machine barcodes everything it owns. It does not own Broskie.
    if (locked) {
      final chainPaint = Paint()
        ..color = Colors.white38
        ..strokeWidth = 4;
      canvas.drawLine(
          const Offset(4, 4), Offset(size.x - 4, size.y - 4), chainPaint);
      canvas.drawLine(Offset(size.x - 4, 4), Offset(4, size.y - 4), chainPaint);
      canvas.drawRect(Rect.fromLTWH(4, size.y - 26, size.x - 8, 18),
          Paint()..color = Colors.black87);
      drawBarcode(canvas, Rect.fromLTWH(7, size.y - 24, size.x - 14, 14),
          seed: 404, color: BroskieColors.bone);
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: locked ? "LOCKED" : "EXIT\nPORTAL",
        style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'monospace'),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset((size.x - textPainter.width) / 2,
            (size.y - textPainter.height) / 2));
  }
}
