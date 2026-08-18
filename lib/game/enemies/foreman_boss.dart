import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../broskie_game.dart';
import '../models/runtime_assets.dart';
import '../player.dart';
import '../services/game_feedback.dart';

enum ForemanPhase { chilling, mad, berserk }

enum ForemanAttackState { patrol, telegraphCharge, charging, stunned }

class TheForeman extends PositionComponent
    with CollisionCallbacks, HasGameReference<BroskieGame> {
  TheForeman({
    required super.position,
    required this.arenaLeft,
    required this.arenaRight,
  }) : super(size: Vector2(126, 78), priority: 8) {
    add(RectangleHitbox());
  }

  static const int maxHealth = 6;

  final double arenaLeft;
  final double arenaRight;
  int health = maxHealth;
  late final Sprite _sprite;
  int direction = -1;
  ForemanAttackState attackState = ForemanAttackState.patrol;
  double _hurtCooldown = 0;
  double _attackTimer = 2.4;
  double _stateTimer = 0;
  int _attackCount = 0;
  bool defeated = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _sprite = Sprite(game.images.fromCache(RuntimeAssets.foreman));
  }

  ForemanPhase get phase {
    if (health <= 2) {
      return ForemanPhase.berserk;
    }
    if (health <= 4) {
      return ForemanPhase.mad;
    }
    return ForemanPhase.chilling;
  }

  double get speed {
    switch (phase) {
      case ForemanPhase.chilling:
        return 105;
      case ForemanPhase.mad:
        return 175;
      case ForemanPhase.berserk:
        return 265;
    }
  }

  double get chargeSpeed {
    switch (phase) {
      case ForemanPhase.chilling:
        return 470;
      case ForemanPhase.mad:
        return 620;
      case ForemanPhase.berserk:
        return 780;
    }
  }

  double get attackInterval {
    switch (phase) {
      case ForemanPhase.chilling:
        return 3.2;
      case ForemanPhase.mad:
        return 2.35;
      case ForemanPhase.berserk:
        return 1.55;
    }
  }

  @override
  void update(double dt) {
    _hurtCooldown = (_hurtCooldown - dt).clamp(0.0, 1.0).toDouble();
    if (!game.isPlaying || defeated) {
      super.update(dt);
      return;
    }

    switch (attackState) {
      case ForemanAttackState.patrol:
        _patrol(dt);
        _attackTimer -= dt;
        if (_attackTimer <= 0) {
          _triggerAttack();
        }
      case ForemanAttackState.telegraphCharge:
        _stateTimer -= dt;
        if (_stateTimer <= 0) {
          attackState = ForemanAttackState.charging;
          _stateTimer = 0.9;
          direction = game.player.x < x ? -1 : 1;
          game.emitFeedback(FeedbackCue.dash);
        }
      case ForemanAttackState.charging:
        x += direction * chargeSpeed * dt;
        _stateTimer -= dt;
        final hitEdge = x <= arenaLeft || x + width >= arenaRight;
        if (hitEdge || _stateTimer <= 0) {
          x = x.clamp(arenaLeft, arenaRight - width).toDouble();
          _crashAndStun();
        }
      case ForemanAttackState.stunned:
        _stateTimer -= dt;
        if (_stateTimer <= 0) {
          attackState = ForemanAttackState.patrol;
          _attackTimer = attackInterval;
        }
    }
    super.update(dt);
  }

  void _patrol(double dt) {
    x += direction * speed * dt;
    if (x <= arenaLeft) {
      x = arenaLeft;
      direction = 1;
    } else if (x + width >= arenaRight) {
      x = arenaRight - width;
      direction = -1;
    }
  }

  void _triggerAttack() {
    _attackCount++;
    if (_attackCount.isOdd) {
      attackState = ForemanAttackState.telegraphCharge;
      _stateTimer = phase == ForemanPhase.berserk ? 0.35 : 0.62;
      game.showBroadcast('FOREMAN: MANDATORY EXPRESS RESTRUCTURING!');
    } else {
      _attackTimer = attackInterval;
      game.world.add(
        ForemanWreckingBall(position: Vector2(game.player.center.x - 24, 18)),
      );
      game.showBroadcast('FOREMAN: OVERHEAD COSTS INCOMING!');
    }
  }

  void _crashAndStun() {
    attackState = ForemanAttackState.stunned;
    _stateTimer = phase == ForemanPhase.berserk ? 0.85 : 1.35;
    game.world.addAll([
      ForemanShockwave(
        position: Vector2(x, BroskieGame.groundY - 24),
        direction: -1,
      ),
      ForemanShockwave(
        position: Vector2(x + width, BroskieGame.groundY - 24),
        direction: 1,
      ),
    ]);
    game.showBroadcast('FOREMAN STUNNED — STOMP NOW!');
    game.emitFeedback(FeedbackCue.bossHit);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (defeated || _hurtCooldown > 0 || other is! Player) {
      return;
    }

    final stomped =
        other.velocity.y > 0 && other.previousBottom <= y + height * 0.5;
    if (stomped) {
      final damage = attackState == ForemanAttackState.stunned ? 2 : 1;
      health -= damage;
      _hurtCooldown = 0.55;
      if (attackState == ForemanAttackState.stunned) {
        attackState = ForemanAttackState.patrol;
        _attackTimer = 1.0;
      }
      direction = other.x < x ? 1 : -1;
      other.bounce();
      game.addFlow(16);
      game.bossDamaged(health, maxHealth);
      if (health <= 0) {
        defeated = true;
        game.bossDefeated();
        removeFromParent();
      }
    } else {
      other.takeHit(sourceDirection: x > other.x ? 1 : -1);
    }
  }

  @override
  void render(Canvas canvas) {
    if (_hurtCooldown > 0 && (_hurtCooldown * 18).floor().isOdd) {
      return;
    }

    canvas.save();
    if (direction > 0) {
      canvas.translate(width, 0);
      canvas.scale(-1, 1);
    }
    _sprite.render(
      canvas,
      position: Vector2(-24, -9),
      size: Vector2(width + 48, height + 18),
    );
    canvas.restore();

    if (phase == ForemanPhase.berserk) {
      canvas.drawRect(
        Rect.fromLTWH(-8, -4, width + 16, height + 8),
        Paint()..color = const Color(0x22FF3158),
      );
    }
    if (attackState == ForemanAttackState.telegraphCharge) {
      final warning = Paint()..color = const Color(0xFFFF3158);
      canvas.drawCircle(Offset(width / 2, -28), 15, warning);
      final painter = TextPainter(
        text: const TextSpan(
          text: '!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(width / 2 - painter.width / 2, -42));
    }
    if (attackState == ForemanAttackState.stunned) {
      for (var i = 0; i < 3; i++) {
        final angle = i * math.pi * 2 / 3 + _stateTimer * 4;
        canvas.drawCircle(
          Offset(width / 2 + math.cos(angle) * 34, -10 + math.sin(angle) * 8),
          4,
          Paint()..color = const Color(0xFFFFEC3D),
        );
      }
    }

    final healthRatio = health / maxHealth;
    canvas.drawRect(
      const Rect.fromLTWH(4, -13, 118, 8),
      Paint()..color = const Color(0xFF181622),
    );
    canvas.drawRect(
      Rect.fromLTWH(6, -11, 114 * healthRatio, 4),
      Paint()..color = const Color(0xFFFF3A54),
    );
  }
}

class ForemanShockwave extends PositionComponent
    with CollisionCallbacks, HasGameReference<BroskieGame> {
  ForemanShockwave({required super.position, required this.direction})
    : super(size: Vector2(42, 24), priority: 9) {
    add(RectangleHitbox());
  }

  final int direction;
  double _life = 2.6;

  @override
  void update(double dt) {
    x += direction * 340 * dt;
    _life -= dt;
    if (_life <= 0) {
      removeFromParent();
    }
    super.update(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      other.takeHit(sourceDirection: direction);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFFF8A32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    for (var i = 0; i < 3; i++) {
      canvas.drawArc(
        Rect.fromLTWH(i * 8.0, 3 + i * 3, 24, 30),
        math.pi,
        math.pi,
        false,
        paint,
      );
    }
  }
}

class ForemanWreckingBall extends PositionComponent
    with CollisionCallbacks, HasGameReference<BroskieGame> {
  ForemanWreckingBall({required super.position})
    : super(size: Vector2.all(48), priority: 9) {
    add(CircleHitbox());
  }

  double _warningTimer = 0.72;
  double _fallSpeed = 60;
  bool _landed = false;

  @override
  void update(double dt) {
    if (_warningTimer > 0) {
      _warningTimer -= dt;
    } else {
      _fallSpeed += 1100 * dt;
      y += _fallSpeed * dt;
      if (!_landed && y + height >= BroskieGame.groundY) {
        _landed = true;
        y = BroskieGame.groundY - height;
        game.world.addAll([
          ForemanShockwave(
            position: Vector2(x, BroskieGame.groundY - 24),
            direction: -1,
          ),
          ForemanShockwave(
            position: Vector2(x + width, BroskieGame.groundY - 24),
            direction: 1,
          ),
        ]);
        game.emitFeedback(FeedbackCue.bossHit);
        removeFromParent();
      }
    }
    super.update(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (_warningTimer <= 0 && other is Player) {
      other.takeHit(sourceDirection: x > other.x ? 1 : -1);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_warningTimer > 0) {
      final targetY = BroskieGame.groundY - y;
      canvas.drawLine(
        Offset(width / 2, height),
        Offset(width / 2, targetY),
        Paint()
          ..color = const Color(0x99FF3158)
          ..strokeWidth = 3,
      );
      canvas.drawCircle(
        Offset(width / 2, targetY),
        18,
        Paint()
          ..color = const Color(0xFFFF3158)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      return;
    }

    canvas.drawLine(
      Offset(width / 2, -32),
      Offset(width / 2, 4),
      Paint()
        ..color = const Color(0xFF697386)
        ..strokeWidth = 5,
    );
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      width / 2,
      Paint()..color = const Color(0xFF333B49),
    );
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final center = Offset(width / 2, height / 2);
      canvas.drawLine(
        center,
        center + Offset(math.cos(angle), math.sin(angle)) * 31,
        Paint()
          ..color = const Color(0xFF111722)
          ..strokeWidth = 5,
      );
    }
  }
}
