import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/broskie_game.dart';

enum DebuffType { slow, lowJump, invertedControls, noDash }

class HaterCloud extends SpriteComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  double timer = 0;
  final double attackInterval = 3.0;

  HaterCloud({required Vector2 position}) : super(position: position, size: Vector2(64, 48)) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer += dt;

    if (timer >= attackInterval) {
      timer = 0;
      _performRandomAttack();
    }
    
    position.x += sin(timer * 3) * 30 * dt;
  }

  void _performRandomAttack() {
    gameRef.showDialogue("HATER CLOUD", "L + Ratio + Get Standardized!");
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      super.render(canvas);
      return;
    }

    final cloudPaint = Paint()..color = const Color(0xFF4A148C);
    final darkOutline = Paint()..color = const Color(0xFF1A237E)..style = PaintingStyle.stroke..strokeWidth = 2;
    final eyePaint = Paint()..color = Colors.redAccent;

    // Dark Cloud Circles
    canvas.drawCircle(const Offset(20, 24), 18, cloudPaint);
    canvas.drawCircle(const Offset(36, 18), 22, cloudPaint);
    canvas.drawCircle(const Offset(48, 26), 16, cloudPaint);

    // Angry Eyes
    canvas.drawCircle(const Offset(26, 20), 4, eyePaint);
    canvas.drawCircle(const Offset(42, 20), 4, eyePaint);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), darkOutline);
  }
}

class Debuff {
  final DebuffType type;
  double duration;

  Debuff(this.type, this.duration);
}
