import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/audio_manager.dart';

class DataBitCoin extends SpriteComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  double floatTimer = 0;
  final int value;

  DataBitCoin({required Vector2 position, this.value = 50}) : super(position: position, size: Vector2(20, 20)) {
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
      gameRef.scoreCoins.value += value;
      BroskieAudio.playPickup();
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(const Offset(10, 10), 10, Paint()..color = Colors.amber);
    canvas.drawCircle(const Offset(10, 10), 6, Paint()..color = const Color(0xFF00E5FF));
    canvas.drawCircle(const Offset(10, 10), 2, Paint()..color = Colors.white);
  }
}
