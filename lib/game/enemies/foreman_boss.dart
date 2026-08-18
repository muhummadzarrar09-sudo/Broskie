import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../broskie_game.dart';
import '../models/runtime_assets.dart';
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
  late final Sprite _sprite;
  int direction = -1;
  double _hurtCooldown = 0;
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

  @override
  void update(double dt) {
    _hurtCooldown = (_hurtCooldown - dt).clamp(0.0, 1.0).toDouble();
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
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
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
