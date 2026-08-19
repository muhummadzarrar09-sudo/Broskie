import 'dart:math';
import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/blocks/hazards.dart';
import 'package:broskie_game/game/blocks/interactable_block.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/haptics.dart';
import 'package:broskie_game/game/weapons/vinyl_boomerang.dart';
import 'package:broskie_game/game/world4/hater_cloud.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PowerUpType { none, classic, juggernaut, shockwave }
enum PlayerState { idle, walking, running, jumping, falling, vaulting }

class Player extends SpriteAnimationComponent with KeyboardHandler, HasGameReference<BroskieGame>, CollisionCallbacks {
  // Game-feel tuning
  static const double _jumpBufferTime = 0.12;
  static const double _coyoteTime = 0.10;
  static const double _dashDuration = 0.16;
  static const double _dashSpeed = 950;
  static const double _dashCooldownTime = 0.7;

  Player({required Vector2 position}) : super(position: position, size: Vector2(48, 48)) {
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

  // Jump assistance + dash state
  double jumpBufferTimer = 0;
  double coyoteTimer = 0;
  double dashTimer = 0;
  double dashCooldown = 0;

  // Loaded AI sprite sheets (procedural painter is the fallback)
  bool artLoaded = false;
  bool artFlipped = false;
  SpriteAnimation? idleAnim;
  SpriteAnimation? walkAnim;
  SpriteAnimation? voltIdleAnim;
  SpriteAnimation? voltWalkAnim;

  // Modern State
  bool controlsInverted = false;
  double hackTimer = 0;
  List<Debuff> activeDebuffs = [];

  // Particle list for retro pixel effects
  final List<PixelParticle> particles = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final walkSheet = await gameRef.images.load('runtime/broskie_walk_sheet.png');
      final voltSheet = await gameRef.images.load('runtime/broskie_volt_walk_sheet.png');
      const frameCount = 4;
      final frameSize = Vector2(walkSheet.width / frameCount, walkSheet.height.toDouble());
      final voltFrameSize = Vector2(voltSheet.width / frameCount, voltSheet.height.toDouble());
      walkAnim = SpriteAnimation.fromFrameData(
        walkSheet,
        SpriteAnimationData.sequenced(amount: frameCount, stepTime: 0.12, textureSize: frameSize),
      );
      idleAnim = SpriteAnimation.fromFrameData(
        walkSheet,
        SpriteAnimationData.sequenced(amount: 1, stepTime: 1, textureSize: frameSize),
      );
      voltWalkAnim = SpriteAnimation.fromFrameData(
        voltSheet,
        SpriteAnimationData.sequenced(amount: frameCount, stepTime: 0.10, textureSize: voltFrameSize),
      );
      voltIdleAnim = SpriteAnimation.fromFrameData(
        voltSheet,
        SpriteAnimationData.sequenced(amount: 1, stepTime: 1, textureSize: voltFrameSize),
      );
      animation = idleAnim;
      artLoaded = true;
    } catch (_) {
      // Sheets missing: the hand-drawn pixel Broskie keeps the game running.
    }
  }

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
    if (dashCooldown > 0) dashCooldown -= dt;

    // Coyote time: grounded refreshes the window, air time burns it down.
    if (isGrounded) {
      coyoteTimer = _coyoteTime;
    } else if (coyoteTimer > 0) {
      coyoteTimer -= dt;
    }

    // Jump buffer: a press just before landing still jumps.
    if (jumpBufferTimer > 0) jumpBufferTimer -= dt;
    if (jumpBufferTimer > 0 && (isGrounded || coyoteTimer > 0) && state != PlayerState.vaulting) {
      _performJump();
    }

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

    if (dashTimer > 0) {
      // Dash owns the horizontal axis for its duration.
      dashTimer -= dt;
      velocity.x = facing * _dashSpeed;
    } else {
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
    }

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

    // Animation Frame Clock (procedural painter path)
    animTimer += dt;
    double frameDuration = isRunning ? 0.06 : 0.12;
    if (animTimer >= frameDuration) {
      animTimer = 0;
      animFrame = (animFrame + 1) % 8;
    }

    // Sprite sheet selection when the AI art is loaded
    if (artLoaded) {
      final moving = state == PlayerState.walking || state == PlayerState.running || dashTimer > 0;
      final volt = currentPower != PowerUpType.none;
      final next = volt ? (moving ? voltWalkAnim : voltIdleAnim) : (moving ? walkAnim : idleAnim);
      if (animation != next) animation = next;

      final shouldFlip = facing == -1;
      if (shouldFlip != artFlipped) {
        flipHorizontallyAroundCenter();
        artFlipped = shouldFlip;
      }
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

    // Dash afterimage trail
    if (dashTimer > 0) {
      particles.add(PixelParticle(
        position: Vector2(position.x + (facing == 1 ? 0 : size.x - 4), position.y + 8 + Random().nextDouble() * size.y - 8),
        velocity: Vector2(-facing * 60, 0),
        color: const Color(0xFFFFD700),
        lifetime: 0.2,
      ));
    }

    // Update Particles
    for (final p in particles) {
      p.update(dt);
    }
    particles.removeWhere((p) => p.isDead);

    position += velocity * dt;

    if (position.y > 1400) {
      gameRef.onPlayerFell();
    }

    super.update(dt);
  }

  void _performJump() {
    jumpBufferTimer = 0;
    coyoteTimer = 0;
    velocity.y = -jumpStrength;
    isGrounded = false;
    BroskieAudio.playJump();

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

  /// Both keyboard and touch route through the buffer so press timing is fair.
  void requestJump() {
    jumpBufferTimer = _jumpBufferTime;
  }

  void tryDash() {
    if (dashCooldown > 0) return;
    dashTimer = _dashDuration;
    dashCooldown = _dashCooldownTime;
    BroskieAudio.playDash();
    if (gameRef.hapticsEnabled.value) BroskieHaptics.light();
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
    isRunning = keysPressed.contains(LogicalKeyboardKey.shiftLeft) || keysPressed.contains(LogicalKeyboardKey.shiftRight);

    final jumpHeld = keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);

    if (jumpHeld && event is KeyDownEvent) {
      requestJump();
    }
    // Variable jump height: releasing a JUMP key early cuts the rise short.
    if (event is KeyUpEvent &&
        (event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.arrowUp ||
            event.logicalKey == LogicalKeyboardKey.keyW) &&
        !jumpHeld &&
        velocity.y < -60) {
      velocity.y *= 0.45;
    }

    // Dash: K or Ctrl.
    if ((keysPressed.contains(LogicalKeyboardKey.keyK) || keysPressed.contains(LogicalKeyboardKey.controlLeft)) &&
        event is KeyDownEvent) {
      tryDash();
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
    size = Vector2(48, 64);
    position.y -= 16;
  }

  void hit() {
    if (isInvulnerable) return;
    BroskieAudio.playHit();
    if (gameRef.hapticsEnabled.value) BroskieHaptics.medium();

    if (isBig) {
      // Power absorb: shrink back to small Broskie, keep the heart.
      isBig = false;
      currentPower = PowerUpType.none;
      size = Vector2(48, 48);
      position.y += 16;
      _applyKnockback();
      isInvulnerable = true;
      invulnerableTimer = 1.5;
      return;
    }

    gameRef.hp.value -= 1;
    if (gameRef.hp.value <= 0) {
      gameOver();
      return;
    }
    _applyKnockback();
    isInvulnerable = true;
    invulnerableTimer = 1.5;
    gameRef.triggerScreenShake(intensity: 0.7);
  }

  void _applyKnockback() {
    velocity.y = -260;
    velocity.x = -facing * 260;
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
        // Rest 0.5px into the surface so grounding stays stable frame to frame.
        position.y = otherTop - size.y + 0.5;
        isGrounded = true;

        if (other is CrumblingPlatform) {
          other.stepOn();
        }
      } else if (velocity.y < 0 && playerTop <= otherBottom && (playerTop - velocity.y * 0.05) >= otherBottom - 14) {
        velocity.y = 0;
        position.y = otherBottom;
      } else {
        // Side hit: platforms and blocks are solid walls from the side too.
        final playerCenterX = position.x + size.x / 2;
        final otherCenterX = other.position.x + other.size.x / 2;
        if (playerCenterX < otherCenterX) {
          position.x = other.position.x - size.x;
        } else {
          position.x = other.position.x + other.size.x;
        }
        if (dashTimer <= 0) velocity.x = 0;
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
    for (final p in particles) {
      p.render(canvas, position);
    }

    if (isInvulnerable && (invulnerableTimer * 12).toInt() % 2 == 0) {
      return;
    }

    if (animation != null) {
      super.render(canvas);
      return;
    }

    final double w = size.x;
    final double h = size.y;

    canvas.save();
    canvas.scale(w / 32, 1); // Procedural art was authored for a 32px frame.

    if (facing == -1) {
      canvas.translate(32, 0);
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

    canvas.restore();

    // Aura Powerup Effects
    if (currentPower != PowerUpType.none) {
      final auraColor = currentPower == PowerUpType.juggernaut
          ? const Color(0xFFFFD700).withValues(alpha: 0.5)
          : const Color(0xFF00E5FF).withValues(alpha: 0.5);
      canvas.drawCircle(Offset(w / 2, h / 2 + 8), w * 0.8, Paint()..color = auraColor);
    }
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
    final paint = Paint()..color = color.withValues(alpha: alpha);
    canvas.drawRect(Rect.fromLTWH(position.x - playerPos.x, position.y - playerPos.y, 3, 3), paint);
  }
}
