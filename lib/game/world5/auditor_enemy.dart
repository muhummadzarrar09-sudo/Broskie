import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/broskie_game.dart';

class AuditorEnemy extends SpriteAnimationComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  double attackTimer = 0;
  final double attackCooldown = 4.0;

  AuditorEnemy({required Vector2 position}) : super(position: position, size: Vector2(48, 64)) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    attackTimer += dt;

    if (attackTimer >= attackCooldown) {
      attackTimer = 0;
      _iceSpikeAttack();
    }
  }

  void _iceSpikeAttack() {
    gameRef.showDialogue("AUDITOR", "Your assets are FROZEN! Liquidity audit in progress!");
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      other.hit();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    if (animation != null) {
      super.render(canvas);
      return;
    }

    final suitPaint = Paint()..color = const Color(0xFF006064);
    final icePaint = Paint()..color = Colors.cyanAccent;

    // Auditor Suit
    canvas.drawRect(Rect.fromLTWH(8, 16, 32, 40), suitPaint);
    canvas.drawRect(const Rect.fromLTWH(12, 4, 24, 16), icePaint); // Frozen Head
    canvas.drawRect(const Rect.fromLTWH(16, 12, 16, 4), Paint()..color = Colors.white); // Sunglasses
  }
}
