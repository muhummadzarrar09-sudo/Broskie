import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/blocks/interactable_block.dart';
import 'package:broskie_game/game/world4/hater_cloud.dart';
import 'package:broskie_game/game/weapons/vinyl_boomerang.dart';

enum PowerUpType { none, classic, juggernaut, shockwave }
enum PlayerState { idle, walking, running, jumping, falling, vaulting }

class Player extends SpriteAnimationComponent with KeyboardHandler, HasGameRef<BroskieGame>, CollisionCallbacks {
  Player({required Vector2 position}) : super(position: position, size: Vector2(32, 48)) {
    add(RectangleHitbox());
  }

  final Vector2 velocity = Vector2.zero();
  final double gravity = 1900;
  final double jumpStrength = 700;
  final double walkSpeed = 320;
  final double runSpeed = 600;
  final double acceleration = 2200;
  final double friction = 1600;
  
  bool isGrounded = false;
  int horizontalDirection = 0;
  bool isRunning = false;
  bool isBig = false;
  bool isInvulnerable = false;
  double invulnerableTimer = 0;
  PowerUpType currentPower = PowerUpType.none;

  // Pixel Animation Engine State
  PlayerState state = PlayerState.idle;
  int facing = 1; // 1 Right, -1 Left
  double animTimer = 0;
  int animFrame = 0;
  double vaultTimer = 0;
  double shootCooldown = 0;

  // Modern State
  bool controlsInverted = false;
  double hackTimer = 0;
  List<Debuff> activeDebuffs = [];

  // Particle list for retro pixel effects
  final List<PixelParticle> particles = [];

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

    if (shootCooldown > 0) shootCooldown -= dt;

    // Gravity
    if (!isGrounded && state != PlayerState.vaulting) {
      velocity.y += gravity * dt;
    }

    // Debuffs & Speed
    double speedMod = 1.0;
    activeDebuffs.removeWhere((d) {
      d.duration -= dt;
      if (d.type == DebuffType.slow) speedMod *= 0.5;
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

    // Vaulting State Logic
    if (state == PlayerState.vaulting) {
      vaultTimer -= dt;
      velocity.x = facing * 400;
      velocity.y = -150;
      if (vaultTimer <= 0) {
        state = PlayerState.idle;
      }
    } else {
      // Determine Animation State
      if (!isGrounded) {
        state = velocity.y < 0 ? PlayerState.jumping : PlayerState.falling;
      } else if (velocity.x.abs() > 30) {
        state = isRunning ? PlayerState.running : PlayerState.walking;
      } else {
        state = PlayerState.idle;
      }
    }

    // Animation Frame Clock
    animTimer += dt;
    double frameDuration = isRunning ? 0.06 : 0.12;
    if (animTimer >= frameDuration) {
      animTimer = 0;
      animFrame = (animFrame + 1) % 8;
    }

    // Running Dust/Trail Pixel Particles
    if (isGrounded && velocity.x.abs() > 200 && animFrame % 2 == 0) {
      particles.add(PixelParticle(
        position: Vector2(position.x + (facing == 1 ? 4 : 24), position.y + size.y - 4),
        velocity: Vector2(-facing * 40, -20 - Random().nextDouble() * 30),
        color: const Color(0xFF888888),
        lifetime: 0.25,
      ));
    }

    // Update Particles
    particles.forEach((p) => p.update(dt));
    particles.removeWhere((p) => p.isDead);

    position += velocity * dt;

    if (position.y > 1400) {
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
        velocity.y = -jumpStrength;
        isGrounded = false;

        // Jump Particle Burst
        for (int i = 0; i < 6; i++) {
          particles.add(PixelParticle(
            position: Vector2(position.x + 8 + i * 3, position.y + size.y),
            velocity: Vector2((i - 3) * 30, 20),
            color: const Color(0xFF00E5FF),
            lifetime: 0.3,
          ));
        }
      }
    }

    // Throw Vinyl Boomerang Weapon (Key J or Key F)
    if ((keysPressed.contains(LogicalKeyboardKey.keyJ) || keysPressed.contains(LogicalKeyboardKey.keyF)) && event is KeyDownEvent) {
      throwVinylBoomerang();
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void throwVinylBoomerang() {
    if (shootCooldown > 0) return;
    shootCooldown = 0.4;
    gameRef.add(VinylBoomerang(
      position: Vector2(position.x + (facing == 1 ? size.x : -24), position.y + 12),
      owner: this,
      isLeft: facing == -1,
    ));
  }

  void triggerParkourVault() {
    state = PlayerState.vaulting;
    vaultTimer = 0.35;
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

  void bounce() => velocity.y = -jumpStrength * 0.75;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Floor || other is InteractableBlock || other is MovingPlatform) {
      final playerBottom = position.y + size.y;
      final playerTop = position.y;
      final otherTop = other.position.y;
      final otherBottom = other.position.y + other.size.y;

      if (velocity.y >= 0 && playerBottom >= otherTop && (playerBottom - velocity.y * 0.05) <= otherTop + 14) {
        velocity.y = 0;
        position.y = otherTop - size.y;
        isGrounded = true;

        if (other is CrumblingPlatform) {
          other.stepOn();
        }
      } else if (velocity.y < 0 && playerTop <= otherBottom && (playerTop - velocity.y * 0.05) >= otherBottom - 14) {
        velocity.y = 0;
        position.y = otherBottom;
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Floor || other is InteractableBlock || other is MovingPlatform) {
      isGrounded = false;
    }
  }

  @override
  void render(Canvas canvas) {
    // Render Particles
    particles.forEach((p) => p.render(canvas, position));

    if (animation != null) {
      super.render(canvas);
      return;
    }

    if (isInvulnerable && (invulnerableTimer * 12).toInt() % 2 == 0) {
      return;
    }

    final double w = size.x;
    final double h = size.y;

    canvas.save();

    if (facing == -1) {
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
    }

    // Palette Colors
    final Paint redPaint = Paint()..color = const Color(0xFFE52521);
    final Paint darkRedPaint = Paint()..color = const Color(0xFF990000);
    final Paint skinPaint = Paint()..color = const Color(0xFFFFCC99);
    final Paint blackPaint = Paint()..color = const Color(0xFF111111);
    final Paint whitePaint = Paint()..color = const Color(0xFFFFFFFF);
    final Paint denimPaint = Paint()..color = const Color(0xFF1F4287);
    final Paint bluePantsPaint = Paint()..color = const Color(0xFF0D47A1);

    // Dynamic Frame Calculations
    double headY = 2.0;
    double armShift = 0.0;
    double legL = 0.0;
    double legR = 0.0;

    switch (state) {
      case PlayerState.idle:
        headY = (animFrame % 4 == 0) ? 3.0 : 2.0; // Idle breathing bounce
        legL = 0; legR = 0;
        break;
      case PlayerState.walking:
      case PlayerState.running:
        armShift = sin(animFrame * pi / 4) * 8;
        legL = sin(animFrame * pi / 4) * 10;
        legR = -legL;
        break;
      case PlayerState.jumping:
        headY = 0.0;
        armShift = -10;
        legL = -6; legR = 6;
        break;
      case PlayerState.falling:
        headY = 4.0;
        armShift = 10;
        legL = 6; legR = -6;
        break;
      case PlayerState.vaulting:
        headY = 6.0;
        armShift = -14;
        legL = 12; legR = 12;
        break;
    }

    // Head & Cap
    canvas.drawRect(Rect.fromLTWH(4, headY, 24, 14), skinPaint);
    canvas.drawRect(Rect.fromLTWH(2, headY - 2, 28, 6), redPaint);
    canvas.drawRect(Rect.fromLTWH(-2, headY + 3, 18, 3), darkRedPaint); // Backwards Cap Brim

    // Sunglasses
    canvas.drawRect(Rect.fromLTWH(10, headY + 5, 14, 5), blackPaint);
    canvas.drawRect(Rect.fromLTWH(20, headY + 6, 3, 2), whitePaint);

    // Smile / Expression
    canvas.drawRect(Rect.fromLTWH(14, headY + 12, 8, 2), blackPaint);

    // Upper Body / Vest / White Tee
    canvas.drawRect(Rect.fromLTWH(6, headY + 14, 20, 16), whitePaint);
    canvas.drawRect(Rect.fromLTWH(4, headY + 14, 6, 16), denimPaint);
    canvas.drawRect(Rect.fromLTWH(22, headY + 14, 6, 16), denimPaint);

    // Arms
    canvas.drawRect(Rect.fromLTWH(-2 + armShift * 0.5, headY + 16, 6, 12), skinPaint);
    canvas.drawRect(Rect.fromLTWH(28 - armShift * 0.5, headY + 16, 6, 12), skinPaint);

    // Legs & Pants
    canvas.drawRect(Rect.fromLTWH(6, headY + 30, 8, 12 + legL), bluePantsPaint);
    canvas.drawRect(Rect.fromLTWH(18, headY + 30, 8, 12 + legR), bluePantsPaint);

    // Red Sneakers
    canvas.drawRect(Rect.fromLTWH(4, headY + 42 + legL, 12, 4), redPaint);
    canvas.drawRect(Rect.fromLTWH(16, headY + 42 + legR, 12, 4), redPaint);
    canvas.drawRect(Rect.fromLTWH(4, headY + 45 + legL, 12, 1), whitePaint);
    canvas.drawRect(Rect.fromLTWH(16, headY + 45 + legR, 12, 1), whitePaint);

    // Aura Powerup Effects
    if (currentPower != PowerUpType.none) {
      final auraColor = currentPower == PowerUpType.juggernaut 
          ? const Color(0xFFFFD700).withOpacity(0.5) 
          : const Color(0xFF00E5FF).withOpacity(0.5);
      canvas.drawCircle(Offset(w / 2, h / 2), w * 0.9, Paint()..color = auraColor);
    }

    canvas.restore();
  }
}

class PixelParticle {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double lifetime;
  double age = 0;

  PixelParticle({required this.position, required this.velocity, required this.color, required this.lifetime});

  void update(double dt) {
    age += dt;
    position += velocity * dt;
  }

  bool get isDead => age >= lifetime;

  void render(Canvas canvas, Vector2 playerPos) {
    double alpha = (1.0 - age / lifetime).clamp(0.0, 1.0);
    final paint = Paint()..color = color.withOpacity(alpha);
    canvas.drawRect(Rect.fromLTWH(position.x - playerPos.x, position.y - playerPos.y, 3, 3), paint);
  }
}
