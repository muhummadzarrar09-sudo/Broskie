import 'dart:math';
import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DataBitCoin extends PositionComponent
    with HasGameReference<BroskieGame>, CollisionCallbacks {
  double floatTimer = 0;
  final int value;

  DataBitCoin({required Vector2 position, this.value = 50})
      : super(position: position, size: Vector2(20, 20)) {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    floatTimer += dt * 4;
    position.y += sin(floatTimer) * 12 * dt;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      game.scoreCoins.value += value;
      BroskieAudio.playPickup();
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // DATA-VINYL: a tiny black 7-inch, magenta label, bone spindle hole.
    // Underground crews trade records, not coins.
    const c = Offset(10, 10);
    canvas.drawCircle(c, 10, Paint()..color = Colors.black);
    canvas.drawCircle(
        c,
        8.5,
        Paint()
          ..color = BroskieColors.bone.withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5); // groove sheen
    canvas.drawCircle(c, 4.5, Paint()..color = BroskieColors.magenta);
    canvas.drawCircle(c, 1.8, Paint()..color = BroskieColors.bone);
  }
}
