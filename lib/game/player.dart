import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/blocks/interactable_block.dart';
import 'package:broskie_game/game/world4/hater_cloud.dart';

enum PowerUpType { none, classic, juggernaut, shockwave }

class Player extends SpriteAnimationComponent with KeyboardHandler, HasGameRef<BroskieGame>, CollisionCallbacks {
  Player({required Vector2 position}) : super(position: position, size: Vector2(48, 48)) {
    add(RectangleHitbox());
  }

  final Vector2 velocity = Vector2.zero();
  final double gravity = 1800;
  final double jumpStrength = 650;
  final double walkSpeed = 300;
  final double runSpeed = 550;
  final double acceleration = 1500;
  final double friction = 1200;
  
  bool isGrounded = false;
  int horizontalDirection = 0;
  bool isRunning = false;
  bool isBig = false;
  bool isInvulnerable = false;
  PowerUpType currentPower = PowerUpType.none;

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

    if (!isGrounded) {
      velocity.y += gravity * dt;
    }

    double speedMod = 1.0;
    activeDebuffs.removeWhere((d) {
      d.duration -= dt;
      if (d.type == DebuffType.slow) speedMod = 0.5;
      return d.duration <= 0;
    });

    double targetSpeed = (isRunning ? runSpeed : walkSpeed) * speedMod;

    if (horizontalDirection != 0) {
      velocity.x += horizontalDirection * acceleration * dt;
    } else {
      if (velocity.x.abs() < friction * dt) {
        velocity.x = 0;
      } else {
        velocity.x -= velocity.x.sign * friction * dt;
      }
    }
    velocity.x = velocity.x.clamp(-targetSpeed, targetSpeed);

    position += velocity * dt;
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

    if (keysPressed.contains(LogicalKeyboardKey.space) && event is KeyDownEvent) {
      if (isGrounded) {
        velocity.y = -jumpStrength;
        isGrounded = false;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void grow(PowerUpType type) {
    if (isBig) return;
    isBig = true;
    currentPower = type;
    size = Vector2(48, 96);
    position.y -= 48;
  }

  void hit() {
    if (isInvulnerable) return;
    if (isBig) {
      isBig = false;
      size = Vector2(48, 48);
      isInvulnerable = true;
      Future.delayed(const Duration(seconds: 2), () => isInvulnerable = false);
    } else {
      gameRef.overlays.add('GameOver');
    }
  }

  void bounce() => velocity.y = -jumpStrength * 0.5;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Floor || other is InteractableBlock) {
      if (velocity.y > 0 && (position.y + size.y) < (other.position.y + 10)) {
        velocity.y = 0;
        position.y = other.position.y - size.y;
        isGrounded = true;
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Floor) isGrounded = false;
  }
}
