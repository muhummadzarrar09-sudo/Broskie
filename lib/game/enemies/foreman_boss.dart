import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/audio_manager.dart';

enum BossPhase { chilling, mad, berserk }

class TheForeman extends SpriteAnimationComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  BossPhase phase = BossPhase.chilling;
  int health = 6;
  bool isDizzy = false;
  double speed = 100;
  int direction = -1;
  
  double dazeTimer = 0;
  final double dazeDuration = 6.0;
  double phaseTimer = 0;

  TheForeman({required Vector2 position}) : super(position: position, size: Vector2(128, 96)) {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    phaseTimer += dt;

    if (isDizzy) {
      dazeTimer -= dt;
      if (dazeTimer <= 0) {
        isDizzy = false;
        speed *= 1.2;
      }
    } else {
      position.x += direction * speed * dt;
      
      // Boundary turns
      if (position.x < 1800) {
        direction = 1;
      } else if (position.x > 2800) {
        direction = -1;
      }

      if (health <= 4 && phase == BossPhase.chilling) {
        phase = BossPhase.mad;
        speed = 180;
        gameRef.showDialogue("THE FOREMAN", "Efficiency dropping below KPI thresholds! Initiating AGGRESSIVE RESTRUCTURING!");
      } else if (health <= 2 && phase == BossPhase.mad) {
        phase = BossPhase.berserk;
        speed = 320;
        gameRef.showDialogue("THE FOREMAN", "SYSTEM OVERRIDE! TERMINATE BROSKIE IMMEDIATELY!");
      }
    }
    super.update(dt);
  }

  void hitByReflectedBrick() {
    if (isDizzy) return;
    health--;
    if (health <= 0) die();
  }

  void crashIntoWall() {
    isDizzy = true;
    dazeTimer = dazeDuration;
  }

  void die() {
    BroskieAudio.playHellNa();
    gameRef.enemiesDefeated++;
    gameRef.showDialogue("THE FOREMAN", "System... failure... The Monopoly... will... find... you...");
    removeFromParent();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      final playerBottom = other.position.y + other.size.y;
      final bossTop = position.y;

      if (isDizzy && other.velocity.y > 0 && playerBottom <= bossTop + 24) {
        health -= 2;
        isDizzy = false;
        other.bounce();
        BroskieAudio.playStomp();
        if (health <= 0) die();
      } else {
        other.hit();
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    if (animation != null) {
      super.render(canvas);
      return;
    }

    canvas.save();

    if (direction == 1) {
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    }

    final yellowPaint = Paint()..color = phase == BossPhase.berserk ? const Color(0xFFD50000) : const Color(0xFFFFAB00);
    final darkMetal = Paint()..color = const Color(0xFF263238);
    final eyePaint = Paint()..color = isDizzy ? Colors.yellow : (phase == BossPhase.berserk ? Colors.cyanAccent : Colors.red);

    // Excavator Main Body
    canvas.drawRect(const Rect.fromLTWH(20, 20, 88, 56), yellowPaint);
    canvas.drawRect(const Rect.fromLTWH(40, 10, 48, 30), darkMetal); // Cockpit Screen

    // Evil Eyes Screen
    canvas.drawRect(const Rect.fromLTWH(48, 16, 12, 12), eyePaint);
    canvas.drawRect(const Rect.fromLTWH(68, 16, 12, 12), eyePaint);

    // Tread Tracks
    canvas.drawRect(const Rect.fromLTWH(10, 72, 108, 20), darkMetal);
    canvas.drawRect(const Rect.fromLTWH(10, 72, 108, 4), Paint()..color = Colors.black);

    // Crane Arm & Wrecking Ball
    final chainPaint = Paint()..color = Colors.grey..strokeWidth = 3;
    canvas.drawLine(const Offset(20, 30), const Offset(-10, -10), chainPaint);
    canvas.drawCircle(const Offset(-10, 15), 14, Paint()..color = Colors.black); // Wrecking ball

    // In-Game Dynamic Health Bar above Boss
    final double healthPercent = (health / 6.0).clamp(0.0, 1.0);
    canvas.drawRect(const Rect.fromLTWH(14, -16, 100, 8), Paint()..color = Colors.black);
    canvas.drawRect(Rect.fromLTWH(16, -14, 96 * healthPercent, 4), Paint()..color = Colors.redAccent);

    canvas.restore();
  }
}
