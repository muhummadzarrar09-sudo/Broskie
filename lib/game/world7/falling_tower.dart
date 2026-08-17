import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/broskie_game.dart';

class FallingTower extends PositionComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  double fallSpeed = 50.0;
  final double maxFallSpeed = 300.0;

  FallingTower({required Vector2 position, required Vector2 size}) : super(position: position, size: size) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    fallSpeed = (fallSpeed + 10 * dt).clamp(0, maxFallSpeed);
    position.y += fallSpeed * dt;

    final player = gameRef.children.whereType<Player>().firstOrNull;
    if (player != null && player.position.y > 700) {
      player.gameOver();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF333333));
  }
}
