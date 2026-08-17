import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../broskie_game.dart';
import '../player.dart';

class DataBrokerBoss extends PositionComponent
    with CollisionCallbacks, HasGameReference<BroskieGame> {
  DataBrokerBoss({
    required super.position,
    required this.arenaLeft,
    required this.arenaRight,
  }) : super(size: Vector2(142, 92), priority: 8) {
    add(RectangleHitbox());
  }

  static const int maxHealth = 10;

  final double arenaLeft;
  final double arenaRight;
  int health = maxHealth;
  int direction = -1;
  int _attackIndex = 0;
  double _attackTimer = 1.8;
  double _hurtCooldown = 0;
  double _time = 0;
  late final double _originY = y;
  bool defeated = false;

  double get speed => health <= 3 ? 210 : (health <= 6 ? 145 : 95);

  @override
  void update(double dt) {
    _time += dt;
    _attackTimer -= dt;
    _hurtCooldown = math.max(0.0, _hurtCooldown - dt);
    if (game.isPlaying && !defeated) {
      x += direction * speed * dt;
      y = _originY + math.sin(_time * 2.2) * 22;
      if (x <= arenaLeft) {
        x = arenaLeft;
        direction = 1;
      } else if (x + width >= arenaRight) {
        x = arenaRight - width;
        direction = -1;
      }
      if (_attackTimer <= 0) {
        _attackTimer = health <= 3 ? 1.35 : 2.15;
        _attack();
      }
    }
    super.update(dt);
  }

  void _attack() {
    switch (_attackIndex % 3) {
      case 0:
        for (var lane = 0; lane < 3; lane++) {
          game.world.add(
            DataPulse(
              position: Vector2(
                x + width / 2,
                BroskieGame.groundY - 28.0 - lane * 34.0,
              ),
              direction: game.player.x < x ? -1 : 1,
              speed: 250.0 + lane * 38.0,
            ),
          );
        }
      case 1:
        game.hackControls(4);
        game.showBroadcast('DATA BROKER: YOUR INPUTS BELONG TO ME.');
      case 2:
        direction = game.player.x < x ? -1 : 1;
        game.addFlow(5);
    }
    _attackIndex++;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (defeated || _hurtCooldown > 0 || other is! Player) {
      return;
    }
    final stomped =
        other.velocity.y > 0 && other.previousBottom <= y + height * 0.48;
    if (stomped) {
      health--;
      _hurtCooldown = 0.45;
      other.bounce();
      game.addFlow(14);
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
    if (_hurtCooldown > 0 && (_hurtCooldown * 20).floor().isOdd) {
      return;
    }
    final shell = health <= 3
        ? const Color(0xFFFF3158)
        : const Color(0xFF8D4DFF);
    final metal = Paint()..color = const Color(0xFF1C2438);
    final neon = Paint()..color = shell;
    final eye = Paint()..color = const Color(0xFF55FF8A);

    canvas.drawOval(const Rect.fromLTWH(18, 14, 106, 62), metal);
    canvas.drawOval(const Rect.fromLTWH(29, 23, 84, 43), neon);
    canvas.drawRect(const Rect.fromLTWH(48, 33, 46, 24), metal);
    canvas.drawRect(const Rect.fromLTWH(59, 40, 9, 8), eye);
    canvas.drawRect(const Rect.fromLTWH(76, 40, 9, 8), eye);
    for (var leg = 0; leg < 4; leg++) {
      final left = 16.0 + leg * 27;
      canvas.drawLine(
        Offset(left + 8, 66),
        Offset(left, 90),
        Paint()
          ..color = shell
          ..strokeWidth = 7,
      );
    }

    canvas.drawRect(
      const Rect.fromLTWH(10, -13, 122, 8),
      Paint()..color = const Color(0xFF181622),
    );
    canvas.drawRect(
      Rect.fromLTWH(12, -11, 118 * (health / maxHealth), 4),
      Paint()..color = const Color(0xFF55FF8A),
    );
  }
}

class DataPulse extends PositionComponent
    with CollisionCallbacks, HasGameReference<BroskieGame> {
  DataPulse({
    required super.position,
    required this.direction,
    required this.speed,
  }) : super(size: Vector2(30, 22), priority: 7) {
    add(CircleHitbox());
  }

  final int direction;
  final double speed;

  @override
  void update(double dt) {
    x += direction * speed * dt;
    angle += direction * dt * 5;
    if (x < -100 || x > game.levelWidth + 100) {
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
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      width / 2,
      Paint()..color = const Color(0x5555FF8A),
    );
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      7,
      Paint()..color = const Color(0xFF55FF8A),
    );
  }
}
