import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Touching the flag moves Broskie's respawn point to this spot.
/// The next fall or stage hazard sends him back here instead of the start.
class CheckpointFlag extends PositionComponent with HasGameReference<BroskieGame>, CollisionCallbacks {
  bool activated = false;
  double waveTimer = 0;

  CheckpointFlag({required Vector2 position}) : super(position: position, size: Vector2(24, 64)) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    waveTimer += dt;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !activated) {
      activated = true;
      gameRef.setCheckpoint(Vector2(position.x + size.x / 2, position.y + size.y));
      BroskieAudio.playPowerup();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    final polePaint = Paint()..color = const Color(0xFF9E9E9E);
    final flagPaint = Paint()
      ..color = activated ? const Color(0xFF00FF66) : const Color(0xFF00E5FF).withValues(alpha: 0.55);

    // Base + pole
    canvas.drawRect(Rect.fromLTWH(0, size.y - 6, size.x, 6), Paint()..color = Colors.black54);
    canvas.drawRect(Rect.fromLTWH(size.x / 2 - 1.5, 0, 3, size.y - 6), polePaint);

    // Flag pennant with a little sway
    final sway = activated ? 0.0 : (waveTimer % 1.0) * 2;
    final flag = Path()
      ..moveTo(size.x / 2 + 1.5, 4)
      ..lineTo(size.x + 12 + sway, 12)
      ..lineTo(size.x / 2 + 1.5, 20)
      ..close();
    canvas.drawPath(flag, flagPaint);

    // Activated glow ring
    if (activated) {
      canvas.drawCircle(Offset(size.x / 2, 12), 10, Paint()..color = const Color(0xFF00FF66).withValues(alpha: 0.25));
    }
  }
}
