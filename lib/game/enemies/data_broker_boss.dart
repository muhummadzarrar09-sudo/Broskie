import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/audio_manager.dart';

class DataBrokerBoss extends SpriteAnimationComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  int health = 8;
  double attackTimer = 0;
  final Random _rng = Random();
  bool isFake = true;

  DataBrokerBoss({required Vector2 position}) : super(position: position, size: Vector2(120, 80)) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    attackTimer += dt;

    if (attackTimer > 4.0) {
      attackTimer = 0;
      _triggerRandomAttack();
    }
  }

  void _triggerRandomAttack() {
    int attackType = _rng.nextInt(3);

    switch (attackType) {
      case 0:
        _laserWeb();
        break;
      case 1:
        _controlHack();
        break;
      case 2:
        _spawnGlitchClones();
        break;
    }
  }

  void _laserWeb() {
    BroskieAudio.playGlitch();
    gameRef.showDialogue("DATA-BROKER", "Spider in the web... Scanning user bandwidth!");
  }

  void _controlHack() {
    BroskieAudio.playGlitch();
    gameRef.showDialogue("DATA-BROKER", "Hacking your neural link! Controls inverted!");
    final player = gameRef.children.whereType<Player>().firstOrNull;
    if (player != null) {
      player.controlsInverted = true;
      player.hackTimer = 5.0;
    }
  }

  void _spawnGlitchClones() {
    BroskieAudio.playGlitch();
    gameRef.showDialogue("DATA-BROKER", "I have your data. I have YOU.");
  }

  void hit() {
    health--;
    if (isFake && health <= 4) {
      _triggerFakeOut();
    }
    if (health <= 0) {
      removeFromParent();
    }
  }

  void _triggerFakeOut() {
    isFake = false;
    health = 8;
    gameRef.showDialogue("DATA-BROKER", "That was just a proxy, Broskie... NOW WE GOING LIVE!");
  }

  @override
  void render(Canvas canvas) {
    if (animation != null) {
      super.render(canvas);
      return;
    }

    final spiderBody = Paint()..color = isFake ? const Color(0xFF1E88E5) : const Color(0xFFD32F2F);
    final legPaint = Paint()..color = Colors.cyanAccent..strokeWidth = 3;
    final eyePaint = Paint()..color = Colors.redAccent;

    // Mech Chassis
    canvas.drawOval(const Rect.fromLTWH(20, 20, 80, 50), spiderBody);

    // Glowing Cyber Eye
    canvas.drawCircle(const Offset(60, 45), 10, eyePaint);
    canvas.drawCircle(const Offset(60, 45), 4, Paint()..color = Colors.white);

    // Spider Legs
    for (int i = 0; i < 4; i++) {
      double xOffset = 25.0 + i * 20;
      canvas.drawLine(Offset(xOffset, 30), Offset(xOffset - 15, 75), legPaint);
      canvas.drawLine(Offset(xOffset, 30), Offset(xOffset + 15, 75), legPaint);
    }
  }
}
