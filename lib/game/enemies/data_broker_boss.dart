import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../broskie_game.dart';
import '../models/runtime_assets.dart';
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
  late final Sprite _sprite;
  int direction = -1;
  int _attackIndex = 0;
  double _attackTimer = 1.8;
  double _hurtCooldown = 0;
  double _time = 0;
  late final double _originY = y;
  bool defeated = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _sprite = Sprite(game.images.fromCache(RuntimeAssets.dataBroker));
  }

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
    canvas.save();
    if (direction > 0) {
      canvas.translate(width, 0);
      canvas.scale(-1, 1);
    }
    _sprite.render(
      canvas,
      position: Vector2(-35, -6),
      size: Vector2(width + 70, height + 12),
    );
    canvas.restore();

    if (health <= 3) {
      canvas.drawRect(
        Rect.fromLTWH(-14, -5, width + 28, height + 10),
        Paint()..color = const Color(0x22FF3158),
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
