import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../broskie_game.dart';
import '../player.dart';

enum ForemanPhase { chilling, mad, berserk }

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
  int direction = -1;
  double _hurtCooldown = 0;
  bool defeated = false;

  ForemanPhase get phase {
    if (health <= 2) {
      return ForemanPhase.berserk;
    }
    if (health <= 4) {
      return ForemanPhase.mad;
    }
    return ForemanPhase.chilling;
  }

  double get speed => switch (phase) {
    ForemanPhase.chilling => 105,
    ForemanPhase.mad => 175,
    ForemanPhase.berserk => 265,
  };

  @override
  void update(double dt) {
    _hurtCooldown = (_hurtCooldown - dt).clamp(0.0, 1.0);
    if (game.isPlaying && !defeated) {
      x += direction * speed * dt;
      if (x <= arenaLeft) {
        x = arenaLeft;
        direction = 1;
      } else if (x + width >= arenaRight) {
        x = arenaRight - width;
        direction = -1;
      }
    }
    super.update(dt);
  }

  @override
  void onCollision(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollision(intersectionPoints, other);
    if (defeated || _hurtCooldown > 0 || other is! Player) {
      return;
    }

    final stomped =
        other.velocity.y > 0 && other.previousBottom <= y + height * 0.5;
    if (stomped) {
      health--;
      _hurtCooldown = 0.55;
      direction = other.x < x ? 1 : -1;
      other.bounce();
      game.bossDamaged(health);
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

    final machine = switch (phase) {
      ForemanPhase.chilling => const Color(0xFFF3A61D),
      ForemanPhase.mad => const Color(0xFFFF7029),
      ForemanPhase.berserk => const Color(0xFFFF345F),
    };
    final metal = Paint()..color = const Color(0xFF263448);
    final body = Paint()..color = machine;
    final dark = Paint()..color = const Color(0xFF121520);
    final eye = Paint()..color = const Color(0xFFFF2E55);

    canvas.drawRect(const Rect.fromLTWH(8, 20, 110, 48), body);
    canvas.drawRect(const Rect.fromLTWH(20, 8, 84, 22), body);
    canvas.drawRect(const Rect.fromLTWH(28, 26, 68, 30), dark);
    canvas.drawRect(const Rect.fromLTWH(38, 34, 14, 8), eye);
    canvas.drawRect(const Rect.fromLTWH(72, 34, 14, 8), eye);
    canvas.drawRect(const Rect.fromLTWH(48, 51, 30, 4), eye);
    canvas.drawCircle(const Offset(26, 68), 10, metal);
    canvas.drawCircle(const Offset(99, 68), 10, metal);
    canvas.drawRect(const Rect.fromLTWH(0, 9, 30, 8), metal);
    canvas.drawRect(const Rect.fromLTWH(96, 9, 30, 8), metal);

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
