import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'broskie_game.dart';
import 'components/world_components.dart';

class Player extends PositionComponent
    with
        KeyboardHandler,
        CollisionCallbacks,
        HasGameReference<BroskieGame> {
  Player({required super.position})
    : super(size: Vector2(42, 58), priority: 10) {
    add(RectangleHitbox());
  }

  static const double gravity = 1900;
  static const double jumpSpeed = 700;
  static const double walkSpeed = 320;
  static const double runSpeed = 430;
  static const double voltSpeed = 520;
  static const double acceleration = 2100;
  static const double groundFriction = 2600;
  static const double terminalVelocity = 1050;

  final Vector2 velocity = Vector2.zero();

  bool isGrounded = false;
  bool powered = false;
  int facing = 1;
  double previousBottom = 0;

  double _coyoteTimer = 0;
  double _jumpBufferTimer = 0;
  double _invulnerabilityTimer = 0;
  bool _fallHandled = false;

  bool get isInvulnerable => _invulnerabilityTimer > 0;

  double get bottom => y + height;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    game.input.setKeyboard(
      left:
          keysPressed.contains(LogicalKeyboardKey.keyA) ||
          keysPressed.contains(LogicalKeyboardKey.arrowLeft),
      right:
          keysPressed.contains(LogicalKeyboardKey.keyD) ||
          keysPressed.contains(LogicalKeyboardKey.arrowRight),
      running:
          keysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
          keysPressed.contains(LogicalKeyboardKey.shiftRight),
    );

    final jumpKey =
        event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.keyW ||
        event.logicalKey == LogicalKeyboardKey.arrowUp;
    if (event is KeyDownEvent && jumpKey) {
      game.input.queueJump();
    }
    return true;
  }

  @override
  void update(double dt) {
    if (!game.isPlaying) {
      super.update(dt);
      return;
    }

    final frameDt = math.min(dt, 1 / 30);
    previousBottom = bottom;
    _invulnerabilityTimer = math.max(0, _invulnerabilityTimer - frameDt);

    if (game.input.takeJump()) {
      _jumpBufferTimer = 0.12;
    } else {
      _jumpBufferTimer = math.max(0, _jumpBufferTimer - frameDt);
    }

    if (isGrounded) {
      _coyoteTimer = 0.1;
    } else {
      _coyoteTimer = math.max(0.0, _coyoteTimer - frameDt);
    }

    final direction = game.input.horizontalDirection;
    if (direction != 0) {
      facing = direction;
    }
    final maxSpeed = powered
        ? voltSpeed
        : (game.input.isRunning ? runSpeed : walkSpeed);
    final targetX = direction * maxSpeed;
    final changeRate = direction == 0 ? groundFriction : acceleration;
    velocity.x = _moveTowards(
      velocity.x,
      targetX,
      changeRate * frameDt,
    );

    if (_jumpBufferTimer > 0 && _coyoteTimer > 0) {
      velocity.y = -jumpSpeed;
      isGrounded = false;
      _coyoteTimer = 0;
      _jumpBufferTimer = 0;
    }

    velocity.y = math.min(terminalVelocity, velocity.y + gravity * frameDt);

    final maxMovement = math.max(
      velocity.x.abs() * frameDt,
      velocity.y.abs() * frameDt,
    );
    final steps = math.max<int>(1, (maxMovement / 8).ceil());
    final stepDt = frameDt / steps;
    isGrounded = false;
    for (var i = 0; i < steps; i++) {
      _moveHorizontal(velocity.x * stepDt);
      _moveVertical(velocity.y * stepDt);
    }

    x = x.clamp(0.0, game.levelWidth - width);
    if (y > game.logicalHeight + 160 && !_fallHandled) {
      _fallHandled = true;
      game.playerFell();
    }

    super.update(dt);
  }

  void _moveHorizontal(double delta) {
    if (delta == 0) {
      return;
    }
    x += delta;
    for (final surface in game.solids) {
      if (surface.isRemoving || !_bounds.overlaps(surface.collisionBounds)) {
        continue;
      }
      if (delta > 0) {
        x = surface.x - width;
      } else {
        x = surface.x + surface.width;
      }
      velocity.x = 0;
    }
  }

  void _moveVertical(double delta) {
    if (delta == 0) {
      return;
    }

    final oldTop = y;
    final oldBottom = bottom;
    y += delta;
    for (final surface in game.solids) {
      if (surface.isRemoving || !_bounds.overlaps(surface.collisionBounds)) {
        continue;
      }

      if (delta > 0 && oldBottom <= surface.y + 2) {
        y = surface.y - height;
        velocity.y = 0;
        isGrounded = true;
      } else if (delta < 0 && oldTop >= surface.y + surface.height - 2) {
        y = surface.y + surface.height;
        velocity.y = 0;
        surface.onHeadBump(this);
      }
    }
  }

  Rect get _bounds => Rect.fromLTWH(x, y, width, height);

  void activateVoltCola() {
    powered = true;
    game.publishHud();
  }

  void losePower() {
    powered = false;
    _invulnerabilityTimer = 1.5;
    game.publishHud();
  }

  void takeHit({required int sourceDirection}) {
    if (isInvulnerable || !game.isPlaying) {
      return;
    }
    if (powered) {
      losePower();
    } else {
      game.damagePlayer();
      _invulnerabilityTimer = 1.5;
    }
    velocity.setValues(-sourceDirection * 330, -360);
  }

  void bounce() {
    velocity.y = -jumpSpeed * 0.62;
    isGrounded = false;
  }

  void respawn(Vector2 checkpoint) {
    position.setFrom(checkpoint);
    velocity.setZero();
    isGrounded = false;
    _fallHandled = false;
    _invulnerabilityTimer = 2;
  }

  @override
  void render(Canvas canvas) {
    if (isInvulnerable && (_invulnerabilityTimer * 12).floor().isOdd) {
      return;
    }

    if (powered) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-5, -4, width + 10, height + 8),
          const Radius.circular(10),
        ),
        Paint()..color = const Color(0x334CF9FF),
      );
    }

    final skin = Paint()..color = const Color(0xFFE4A067);
    final cap = Paint()..color = const Color(0xFFE51E36);
    final jacket = Paint()..color = const Color(0xFF1678C8);
    final dark = Paint()..color = const Color(0xFF111827);
    final shoe = Paint()..color = const Color(0xFFE51E36);

    canvas.drawRect(const Rect.fromLTWH(10, 8, 24, 18), skin);
    canvas.drawRect(const Rect.fromLTWH(6, 4, 30, 8), cap);
    canvas.drawRect(
      Rect.fromLTWH(facing > 0 ? 31 : 2, 9, 9, 4),
      cap,
    );
    canvas.drawRect(const Rect.fromLTWH(11, 13, 24, 6), dark);
    canvas.drawRect(const Rect.fromLTWH(7, 26, 28, 21), jacket);
    canvas.drawRect(const Rect.fromLTWH(16, 26, 8, 21), Paint()..color = Colors.white);
    canvas.drawRect(const Rect.fromLTWH(8, 47, 11, 8), dark);
    canvas.drawRect(const Rect.fromLTWH(25, 47, 10, 8), dark);
    canvas.drawRect(const Rect.fromLTWH(5, 54, 16, 4), shoe);
    canvas.drawRect(const Rect.fromLTWH(24, 54, 16, 4), shoe);
  }

  double _moveTowards(double current, double target, double maxDelta) {
    if ((target - current).abs() <= maxDelta) {
      return target;
    }
    return current + (target - current).sign * maxDelta;
  }
}
