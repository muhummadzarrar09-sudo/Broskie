import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/blocks/interactable_block.dart';
import 'package:broskie_game/game/world4/hater_cloud.dart';

enum PowerUpType { none, classic, juggernaut, shockwave }

class Player extends SpriteAnimationComponent with KeyboardHandler, HasGameRef<BroskieGame>, CollisionCallbacks {
  Player({required Vector2 position}) : super(position: position, size: Vector2(32, 48)) {
    add(RectangleHitbox());
  }

  final Vector2 velocity = Vector2.zero();
  final double gravity = 1800;
  final double jumpStrength = 650;
  final double walkSpeed = 300;
  final double runSpeed = 550;
  final double acceleration = 2000;
  final double friction = 1500;
  
  bool isGrounded = false;
  int horizontalDirection = 0;
  bool isRunning = false;
  bool isBig = false;
  bool isInvulnerable = false;
  double invulnerableTimer = 0;
  PowerUpType currentPower = PowerUpType.none;

  // Visual/Facing State
  int facing = 1; // 1 = Right, -1 = Left
  double animTimer = 0;
  int walkFrame = 0;

  // Modern State (Hacker Gimmicks)
  bool controlsInverted = false;
  double hackTimer = 0;
  List<Debuff> activeDebuffs = [];

  @override
  void update(double dt) {
    if (controlsInverted) {
      hackTimer -= dt;
      if (hackTimer <= 0) controlsInverted = false;
    }

    if (isInvulnerable) {
      invulnerableTimer -= dt;
      if (invulnerableTimer <= 0) isInvulnerable = false;
    }

    // Gravity
    if (!isGrounded) {
      velocity.y += gravity * dt;
    }

    // Debuffs & Speed Modifiers
    double speedMod = 1.0;
    double jumpMod = 1.0;
    activeDebuffs.removeWhere((d) {
      d.duration -= dt;
      if (d.type == DebuffType.slow) speedMod *= 0.5;
      if (d.type == DebuffType.lowJump) jumpMod *= 0.6;
      return d.duration <= 0;
    });

    double targetSpeed = (isRunning ? runSpeed : walkSpeed) * speedMod;

    if (horizontalDirection != 0) {
      velocity.x += horizontalDirection * acceleration * dt;
      facing = horizontalDirection;
    } else {
      if (velocity.x.abs() < friction * dt) {
        velocity.x = 0;
      } else {
        velocity.x -= velocity.x.sign * friction * dt;
      }
    }
    velocity.x = velocity.x.clamp(-targetSpeed, targetSpeed);

    // Animation frame timer
    animTimer += dt;
    if (animTimer > 0.1) {
      animTimer = 0;
      walkFrame = (walkFrame + 1) % 4;
    }

    position += velocity * dt;

    // Void death check
    if (position.y > 1000) {
      gameOver();
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    int dir = 0;
    if (keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      dir = -1;
    } else if (keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      dir = 1;
    }

    horizontalDirection = controlsInverted ? -dir : dir;
    isRunning = keysPressed.contains(LogicalKeyboardKey.shiftLeft) || keysPressed.contains(LogicalKeyboardKey.keyK);

    if ((keysPressed.contains(LogicalKeyboardKey.space) || keysPressed.contains(LogicalKeyboardKey.arrowUp) || keysPressed.contains(LogicalKeyboardKey.keyW)) && event is KeyDownEvent) {
      if (isGrounded) {
        double jumpMod = activeDebuffs.any((d) => d.type == DebuffType.lowJump) ? 0.6 : 1.0;
        velocity.y = -jumpStrength * jumpMod;
        isGrounded = false;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void grow(PowerUpType type) {
    if (isBig) return;
    isBig = true;
    currentPower = type;
    size = Vector2(32, 64);
    position.y -= 16;
  }

  void hit() {
    if (isInvulnerable) return;
    if (isBig) {
      isBig = false;
      currentPower = PowerUpType.none;
      size = Vector2(32, 48);
      isInvulnerable = true;
      invulnerableTimer = 2.0;
    } else {
      gameOver();
    }
  }

  void gameOver() {
    gameRef.triggerGameOver();
  }

  void bounce() => velocity.y = -jumpStrength * 0.7;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Floor || other is InteractableBlock) {
      final playerBottom = position.y + size.y;
      final playerTop = position.y;
      final otherTop = other.position.y;
      final otherBottom = other.position.y + other.size.y;

      // Vertical landing collision (coming down onto block/floor)
      if (velocity.y >= 0 && playerBottom >= otherTop && (playerBottom - velocity.y * 0.05) <= otherTop + 12) {
        velocity.y = 0;
        position.y = otherTop - size.y;
        isGrounded = true;
      }
      // Hitting head on ceiling/block from below
      else if (velocity.y < 0 && playerTop <= otherBottom && (playerTop - velocity.y * 0.05) >= otherBottom - 12) {
        velocity.y = 0;
        position.y = otherBottom;
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Floor || other is InteractableBlock) {
      isGrounded = false;
    }
  }

  @override
  void render(Canvas canvas) {
    if (animation != null) {
      super.render(canvas);
      return;
    }

    // Invulnerability Blink Effect
    if (isInvulnerable && (invulnerableTimer * 10).toInt() % 2 == 0) {
      return;
    }

    final double w = size.x;
    final double h = size.y;

    canvas.save();

    // Horizontal Facing Flip
    if (facing == -1) {
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
    }

    // 16-Bit Retro Pixel Art Rendering for Broskie
    // Cap (Red with turned brim)
    final Paint redPaint = Paint()..color = const Color(0xFFE52521);
    final Paint darkRedPaint = Paint()..color = const Color(0xFF990000);
    final Paint bluePaint = Paint()..color = const Color(0xFF0066CC);
    final Paint skinPaint = Paint()..color = const Color(0xFFFFCC99);
    final Paint blackPaint = Paint()..color = const Color(0xFF111111);
    final Paint whitePaint = Paint()..color = const Color(0xFFFFFFFF);
    final Paint denimPaint = Paint()..color = const Color(0xFF1F4287);

    // Body offsets for walk/jump animations
    double legOffset = isGrounded ? (horizontalDirection != 0 ? sin(walkFrame * pi / 2) * 4 : 0) : 6;

    // Head & Cap
    canvas.drawRect(Rect.fromLTWH(4, 2, 24, 14), skinPaint); // Head
    canvas.drawRect(Rect.fromLTWH(2, 0, 28, 6), redPaint); // Cap top
    canvas.drawRect(Rect.fromLTWH(facing == 1 ? -2 : 12, 5, 20, 3), darkRedPaint); // Backwards/Forward brim

    // Sunglasses
    canvas.drawRect(Rect.fromLTWH(12, 6, 14, 5), blackPaint);
    canvas.drawRect(Rect.fromLTWH(22, 7, 3, 2), whitePaint); // Glint

    // Cool Smile
    canvas.drawRect(Rect.fromLTWH(16, 13, 8, 2), blackPaint);

    // Vest / White Tee
    canvas.drawRect(Rect.fromLTWH(6, 16, 20, 16), whitePaint); // Tee
    canvas.drawRect(Rect.fromLTWH(4, 16, 6, 16), denimPaint); // Vest Left
    canvas.drawRect(Rect.fromLTWH(22, 16, 6, 16), denimPaint); // Vest Right

    // Arms
    canvas.drawRect(Rect.fromLTWH(0, 18, 4, 12), skinPaint);
    canvas.drawRect(Rect.fromLTWH(28, 18, 4, 12), skinPaint);

    // Pants & Legs (Animated)
    double leftLeg = legOffset;
    double rightLeg = -legOffset;
    canvas.drawRect(Rect.fromLTWH(6, 32, 8, 12 + leftLeg), bluePaint);
    canvas.drawRect(Rect.fromLTWH(18, 32, 8, 12 + rightLeg), bluePaint);

    // Red Sneakers
    canvas.drawRect(Rect.fromLTWH(4, 44 + leftLeg, 12, 4), redPaint);
    canvas.drawRect(Rect.fromLTWH(16, 44 + rightLeg, 12, 4), redPaint);
    canvas.drawRect(Rect.fromLTWH(4, 47 + leftLeg, 12, 1), whitePaint); // Sole
    canvas.drawRect(Rect.fromLTWH(16, 47 + rightLeg, 12, 1), whitePaint);

    // Powerup Aura Effect
    if (currentPower != PowerUpType.none) {
      final auraColor = currentPower == PowerUpType.juggernaut 
          ? const Color(0xFFFFD700).withOpacity(0.4) 
          : const Color(0xFF00FFFF).withOpacity(0.4);
      canvas.drawCircle(Offset(w / 2, h / 2), w * 0.8, Paint()..color = auraColor);
    }

    canvas.restore();
  }
}
