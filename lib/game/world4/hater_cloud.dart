import 'dart:math';
import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum DebuffType { slow, lowJump, invertedControls, noDash }

class HaterCloud extends SpriteComponent with HasGameReference<BroskieGame>, CollisionCallbacks {
  double timer = 0;
  double hoverTime = 0;
  final double attackInterval = 3.0;
  final double effectRange = 340;

  HaterCloud({required Vector2 position}) : super(position: position, size: Vector2(64, 48)) {
    add(RectangleHitbox());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      sprite = Sprite(await game.images.load('runtime/hater_drone.png'));
    } catch (_) {
      // Procedural cloud painter stays active without the art.
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer += dt;
    hoverTime += dt;

    // Toxic aura: players inside the splash zone get slowed, not just insulted.
    if (timer >= attackInterval) {
      timer = 0;
      _performRandomAttack();
    }

    position.x += sin(hoverTime * 3) * 30 * dt;
  }

  void _performRandomAttack() {
    final player = game.children.whereType<Player>().firstOrNull;
    if (player == null) return;
    if ((player.position.x - position.x).abs() > effectRange) return;
    player.activeDebuffs.add(Debuff(DebuffType.slow, 1.5));
    BroskieAudio.playGlitch();
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
