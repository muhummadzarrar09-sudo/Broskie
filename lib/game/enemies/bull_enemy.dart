import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/effects/kill_burst.dart';
import 'package:broskie_game/game/haptics.dart';
import 'package:broskie_game/game/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class WallStreetBull extends SpriteAnimationComponent
    with HasGameReference<BroskieGame>, CollisionCallbacks {
  bool isCharging = false;
  bool isDizzy = false;
  double patrolSpeed = 60;
  double chargeSpeed = 260;
  int direction = -1; // -1 Left, 1 Right
  double stateTimer = 0;
  final double patrolRange;
  late final double _spawnX;
  // Sprite art faces RIGHT (+1). _artDir tracks which way the SPRITE is
  // flipped so we never double-flip or skip a flip.
  int _artDir = 1;

  WallStreetBull({required Vector2 position, this.patrolRange = 260})
      : super(position: position, size: Vector2(64, 48)) {
    _spawnX = position.x;
    add(RectangleHitbox());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final image = await game.images.load('runtime/bulldozer_drone.png');
      animation = SpriteAnimation.spriteList([Sprite(image)], stepTime: 1);
    } catch (_) {
      // Procedural bull painter stays active without the art.
    }
  }

  @override
  void update(double dt) {
    stateTimer += dt;

    // Sprite-art facing flip (the procedural painter flips itself in render).
    if (animation != null && direction != _artDir) {
      flipHorizontallyAroundCenter();
      _artDir = direction;
    }

    if (isDizzy) {
      if (stateTimer > 3.0) {
        isDizzy = false;
        stateTimer = 0;
      }
    } else if (isCharging) {
      position.x +=
          direction * chargeSpeed * game.difficulty.value.enemySpeed * dt;
      if (stateTimer > 2.5) {
        getDizzy();
      }
    } else {
      position.x +=
          direction * patrolSpeed * game.difficulty.value.enemySpeed * dt;
      if (stateTimer > 3.0) {
        startCharge();
      }
    }

    // Stay inside the patrol corridor. Charging into the bound is a real
    // wall crash: the bull goes dizzy and becomes stompable.
    final minX = _spawnX - patrolRange;
    final maxX = _spawnX + patrolRange;
    if (position.x <= minX || position.x >= maxX) {
      position.x = position.x.clamp(minX, maxX);
      if (isCharging) {
        getDizzy();
        BroskieAudio.playBossHit();
      } else if (!isDizzy) {
        direction = -direction;
      }
    }

    super.update(dt);
  }

  void startCharge() {
    isCharging = true;
    stateTimer = 0;
  }

  void getDizzy() {
    isCharging = false;
    isDizzy = true;
    stateTimer = 0;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      final playerBottom = other.position.y + other.size.y;
      final bullTop = position.y;

      if (isDizzy && other.velocity.y > 0 && playerBottom <= bullTop + 16) {
        BroskieAudio.playStomp();
        game.add(KillBurst(
            position: position.clone()..add(size / 2),
            color: const Color(0xFFFFB800)));
        game.hitStop(0.08);
        if (game.hapticsEnabled.value) BroskieHaptics.heavy();
        game.enemiesDefeated++;
        removeFromParent(); // Stomped!
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
      return;
    }

    final bullBody = Paint()
      ..color = isCharging ? const Color(0xFFB71C1C) : const Color(0xFF4E342E);
    final hornPaint = Paint()..color = const Color(0xFFFFD700);
    final eyePaint = Paint()..color = isDizzy ? Colors.yellow : Colors.red;

    canvas.save();

    if (direction == 1) {
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    }

    // Bull Body
    canvas.drawRect(const Rect.fromLTWH(12, 12, 44, 28), bullBody);
    canvas.drawRect(const Rect.fromLTWH(0, 16, 16, 20), bullBody); // Head

    // Gold Horns
    canvas.drawRect(const Rect.fromLTWH(2, 4, 6, 14), hornPaint);
    canvas.drawRect(const Rect.fromLTWH(8, 2, 4, 16), hornPaint);

    // Eyes
    canvas.drawRect(const Rect.fromLTWH(4, 20, 5, 5), eyePaint);

    // Snort Nose Ring
    canvas.drawCircle(const Offset(2, 28), 3, Paint()..color = Colors.amber);

    // Legs
    final legPaint = Paint()..color = Colors.black;
    canvas.drawRect(const Rect.fromLTWH(16, 40, 6, 8), legPaint);
    canvas.drawRect(const Rect.fromLTWH(44, 40, 6, 8), legPaint);

    // Dizzy Stars Above Head
    if (isDizzy) {
      double starOffset = (stateTimer * 10) % 20;
      canvas.drawCircle(
          Offset(20 + starOffset, -6), 4, Paint()..color = Colors.yellow);
      canvas.drawCircle(
          Offset(40 - starOffset, -6), 3, Paint()..color = Colors.amber);
    }

    canvas.restore();
  }
}
