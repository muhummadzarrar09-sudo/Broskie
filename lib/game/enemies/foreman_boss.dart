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
  static const int maxHealth = 6;
  bool isDizzy = false;
  double speed = 100;
  int direction = -1;

  // Arena bounds are explicit so the fight works on any stage.
  final double minX;
  final double maxX;

  // Charge cycle: pace for a while, then telegraph and charge at the player.
  // Charging into an arena edge crashes the Foreman and opens the dizzy window.
  bool isCharging = false;
  double behaviorTimer = 0;
  static const double chargeWindup = 3.5;
  static const double chargeMax = 2.5;

  double dazeTimer = 0;
  final double dazeDuration = 6.0;
  double phaseTimer = 0;

  bool _artLoaded = false;
  int _artDir = -1;

  TheForeman({required Vector2 position, this.minX = 1800, this.maxX = 2800})
      : super(position: position, size: Vector2(148, 80)) {
    add(RectangleHitbox());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Source art faces right; flip once if spawning while moving left.
    if (direction == -1) {
      flipHorizontallyAroundCenter();
      _artDir = -1;
    } else {
      _artDir = 1;
    }
    try {
      final image = await gameRef.images.load('runtime/foreman_boss.png');
      animation = SpriteAnimation.spriteList([Sprite(image)], stepTime: 1);
      _artLoaded = true;
    } catch (_) {
      // Procedural excavator painter stays active without the art.
    }
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
      behaviorTimer += dt;

      if (!isCharging && behaviorTimer > chargeWindup) {
        isCharging = true;
        behaviorTimer = 0;
        final player = gameRef.children.whereType<Player>().firstOrNull;
        if (player != null) {
          direction = player.position.x >= position.x ? 1 : -1;
        }
      }
      if (isCharging && behaviorTimer > chargeMax) {
        isCharging = false;
        behaviorTimer = 0;
      }

      final double moveSpeed = isCharging ? speed * 1.9 : speed;
      position.x += direction * moveSpeed * dt;

      if (position.x <= minX) {
        position.x = minX;
        _hitArenaEdge();
      } else if (position.x >= maxX) {
        position.x = maxX;
        _hitArenaEdge();
      }

      if (_artLoaded) {
        final dir = direction;
        if (dir != _artDir) {
          flipHorizontallyAroundCenter();
          _artDir = dir;
        }
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

  void _hitArenaEdge() {
    if (isCharging) {
      isCharging = false;
      behaviorTimer = 0;
      crashIntoWall();
      gameRef.triggerScreenShake(intensity: 1.1);
      BroskieAudio.playBossHit();
    } else {
      direction = -direction;
    }
  }

  void hitByReflectedBrick() {
    if (isDizzy) return;
    BroskieAudio.playBossHit();
    health--;
    if (health <= 0) die();
  }

  void crashIntoWall() {
    isDizzy = true;
    dazeTimer = dazeDuration;
  }

  void die() {
    BroskieAudio.playBossHit();
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
    } else {
      _renderProcedural(canvas);
    }

    // In-game dynamic health bar above the boss, drawn for both art paths.
    final double healthPercent = (health / maxHealth).clamp(0.0, 1.0);
    final double barLeft = (size.x - 100) / 2;
    canvas.drawRect(Rect.fromLTWH(barLeft - 2, -16, 104, 8), Paint()..color = Colors.black);
    canvas.drawRect(Rect.fromLTWH(barLeft, -14, 100 * healthPercent, 4), Paint()..color = Colors.redAccent);
  }

  void _renderProcedural(Canvas canvas) {
    canvas.save();

    if (direction == 1) {
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    }

    final yellowPaint = Paint()..color = phase == BossPhase.berserk ? const Color(0xFFD50000) : const Color(0xFFFFAB00);
    final darkMetal = Paint()..color = const Color(0xFF263238);
    final eyePaint = Paint()..color = isDizzy ? Colors.yellow : (phase == BossPhase.berserk ? Colors.cyanAccent : Colors.red);
    final double scaleX = size.x / 128;

    // Excavator Main Body
    canvas.drawRect(Rect.fromLTWH(20 * scaleX, 20, 88 * scaleX, 56), yellowPaint);
    canvas.drawRect(Rect.fromLTWH(40 * scaleX, 10, 48 * scaleX, 30), darkMetal); // Cockpit Screen

    // Evil Eyes Screen
    canvas.drawRect(Rect.fromLTWH(48 * scaleX, 16, 12, 12), eyePaint);
    canvas.drawRect(Rect.fromLTWH(68 * scaleX, 16, 12, 12), eyePaint);

    // Tread Tracks
    canvas.drawRect(Rect.fromLTWH(10 * scaleX, 72, 108 * scaleX, 8), darkMetal);
    canvas.drawRect(Rect.fromLTWH(10 * scaleX, 72, 108 * scaleX, 4), Paint()..color = Colors.black);

    // Crane Arm & Wrecking Ball
    final chainPaint = Paint()..color = Colors.grey..strokeWidth = 3;
    canvas.drawLine(Offset(20 * scaleX, 30), Offset(-10, -10), chainPaint);
    canvas.drawCircle(const Offset(-10, 15), 14, Paint()..color = Colors.black); // Wrecking ball

    canvas.restore();
  }
}
