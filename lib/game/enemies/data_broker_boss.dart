import 'dart:math';
import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/haptics.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DataBrokerBoss extends SpriteAnimationComponent
    with HasGameReference<BroskieGame>, CollisionCallbacks {
  int health = 8;
  static const int maxHealth = 8;
  double attackTimer = 0;
  double hoverTimer = 0;
  final Random _rng = Random();
  bool isFake = true;

  // Hover corridor. The boss drifts inside it instead of standing still.
  final double minX;
  final double maxX;
  double _baseY = 0;
  int _driftDir = -1;

  DataBrokerBoss(
      {required Vector2 position, this.minX = 2300, this.maxX = 3200})
      : super(position: position, size: Vector2(140, 72)) {
    add(RectangleHitbox());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _baseY = position.y;
    try {
      final image = await game.images.load('runtime/data_broker_boss.png');
      animation = SpriteAnimation.spriteList([Sprite(image)], stepTime: 1);
    } catch (_) {
      // Procedural spider-mech painter stays active without the art.
    }
    game.showBossBar('DATA-BROKER');
  }

  @override
  void update(double dt) {
    super.update(dt);
    attackTimer += dt;
    hoverTimer += dt;

    position.y = _baseY + sin(hoverTimer * 2.2) * 14;
    position.x += _driftDir * 60 * dt;
    if (position.x <= minX) {
      position.x = minX;
      _driftDir = 1;
    } else if (position.x >= maxX) {
      position.x = maxX;
      _driftDir = -1;
    }

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
    final player = game.children.whereType<Player>().firstOrNull;
    if (player == null) return;

    // A real three-bolt data volley aimed at Broskie's current position.
    final origin = Vector2(position.x + size.x / 2, position.y + size.y / 2);
    final target = Vector2(player.position.x + player.size.x / 2,
        player.position.y + player.size.y / 2);
    final baseDir = (target - origin).normalized();
    for (final angle in [-0.35, 0.0, 0.35]) {
      final dir = baseDir.clone()..rotate(angle);
      game.add(DataBolt(position: origin.clone(), velocity: dir * 320));
    }
  }

  void _controlHack() {
    BroskieAudio.playGlitch();
    game.showDialogue(
        "DATA-BROKER", "Hacking your neural link! Controls inverted!");
    final player = game.children.whereType<Player>().firstOrNull;
    if (player != null) {
      player.controlsInverted = true;
      player.hackTimer = 5.0;
    }
  }

  void _spawnGlitchClones() {
    BroskieAudio.playGlitch();
    // The "clones" were always a proxy trick: the boss blinks to a new spot.
    position.x = minX + _rng.nextDouble() * (maxX - minX);
  }

  void hit() {
    BroskieAudio.playBossHit();
    game.hitStop(0.05);
    health--;
    if (isFake && health <= 4) {
      _triggerFakeOut();
    }
    // Bar updates AFTER the fake-out so the proxy reveal reads as a refill.
    game.updateBossBar(health / maxHealth);
    if (health <= 0) {
      die();
    }
  }

  void _triggerFakeOut() {
    isFake = false;
    health = maxHealth;
    game.showDialogue(
        "DATA-BROKER", "That was just a proxy, Broskie... NOW WE GOING LIVE!");
  }

  void die() {
    // Executive termination: deep freeze, white flash, the sting.
    BroskieAudio.playBossKill();
    game.hitStop(0.35);
    game.triggerScreenFlash(0.85);
    if (game.hapticsEnabled.value) BroskieHaptics.heavy();
    game.hideBossBar();
    game.enemiesDefeated++;
    game.showDialogue("DATA-BROKER",
        "Connection... terminated... The... signal... dies... with... me...");
    removeFromParent();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      final playerBottom = other.position.y + other.size.y;
      final bossTop = position.y;

      if (other.velocity.y > 0 && playerBottom <= bossTop + 20) {
        hit();
        other.bounce();
        other.onStompLockout();
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
    } else {
      _renderProcedural(canvas);
    }

    // Glitch static flickers right before the attack lands — read the tell.
    if (attackTimer > 3.4) {
      final jx = sin(attackTimer * 90) * 3;
      final jy = cos(attackTimer * 70) * 3;
      final glitchPaint = Paint()
        ..color = const Color(0xFFFF3FA4).withValues(alpha: 0.85);
      canvas.drawRect(Rect.fromLTWH(jx - 6, 6 + jy, 16, 6), glitchPaint);
      canvas.drawRect(Rect.fromLTWH(size.x + jx - 10, size.y - 14 + jy, 16, 6),
          glitchPaint);
    }

    // Health bar tracks the CURRENT phase health so the fake-out reads clearly.
    final double healthPercent = (health / maxHealth).clamp(0.0, 1.0);
    final double barLeft = (size.x - 100) / 2;
    canvas.drawRect(
        Rect.fromLTWH(barLeft - 2, -16, 104, 8), Paint()..color = Colors.black);
    canvas.drawRect(Rect.fromLTWH(barLeft, -14, 100 * healthPercent, 4),
        Paint()..color = isFake ? Colors.cyanAccent : Colors.redAccent);
  }

  void _renderProcedural(Canvas canvas) {
    final spiderBody = Paint()
      ..color = isFake ? const Color(0xFF1E88E5) : const Color(0xFFD32F2F);
    final legPaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 3;
    final eyePaint = Paint()..color = Colors.redAccent;
    final double scaleX = size.x / 120;

    // Mech Chassis
    canvas.drawOval(
        Rect.fromLTWH(20 * scaleX, 20, 80 * scaleX, 50), spiderBody);

    // Glowing Cyber Eye
    canvas.drawCircle(Offset(60 * scaleX, 45), 10, eyePaint);
    canvas.drawCircle(
        Offset(60 * scaleX, 45), 4, Paint()..color = Colors.white);

    // Spider Legs
    for (int i = 0; i < 4; i++) {
      double xOffset = (25.0 + i * 20) * scaleX;
      canvas.drawLine(Offset(xOffset, 30), Offset(xOffset - 15, 72), legPaint);
      canvas.drawLine(Offset(xOffset, 30), Offset(xOffset + 15, 72), legPaint);
    }
  }
}

/// A glowing packet of stolen bandwidth aimed at Broskie.
class DataBolt extends PositionComponent
    with HasGameReference<BroskieGame>, CollisionCallbacks {
  final Vector2 velocity;
  double lifetime = 4.0;
  double pulse = 0;

  DataBolt({required Vector2 position, required this.velocity})
      : super(position: position, size: Vector2(18, 18)) {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    pulse += dt * 10;
    lifetime -= dt;
    if (lifetime <= 0) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      other.hit();
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    final glow = Paint()..color = BroskieColors.magenta.withValues(alpha: 0.9);
    final core = Paint()..color = Colors.white;
    final radius = 7 + sin(pulse) * 1.5;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius + 3,
        glow..color = glow.color.withValues(alpha: 0.35));
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius,
        glow..color = BroskieColors.magenta);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 2.5, core);
  }
}
