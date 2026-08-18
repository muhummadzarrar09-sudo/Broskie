import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../broskie_game.dart';
import '../models/runtime_assets.dart';
import '../player.dart';

class GrumpyBrick extends PositionComponent
    with CollisionCallbacks, HasGameReference<BroskieGame> {
  GrumpyBrick({
    required super.position,
    required this.patrolStart,
    required this.patrolEnd,
  }) : super(size: Vector2(38, 38), priority: 7) {
    add(RectangleHitbox());
  }

  final double patrolStart;
  final double patrolEnd;
  double speed = 75;
  late final Sprite _sprite;
  int direction = -1;
  bool defeated = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _sprite = Sprite(game.images.fromCache(RuntimeAssets.corporateCube));
  }

  @override
  void update(double dt) {
    if (game.isPlaying && !defeated) {
      x += direction * speed * dt;
      if (x <= patrolStart) {
        x = patrolStart;
        direction = 1;
      } else if (x + width >= patrolEnd) {
        x = patrolEnd - width;
        direction = -1;
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
    if (defeated || other is! Player) {
      return;
    }

    final stomped =
        other.velocity.y > 0 && other.previousBottom <= y + height * 0.55;
    if (stomped) {
      defeated = true;
      other.bounce();
      game.collectCash(150);
      game.enemyDefeated();
      removeFromParent();
    } else {
      other.takeHit(sourceDirection: x > other.x ? 1 : -1);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    if (direction > 0) {
      canvas.translate(width, 0);
      canvas.scale(-1, 1);
    }
    _sprite.render(
      canvas,
      position: Vector2(-4, -7),
      size: Vector2(width + 8, height + 10),
    );
    canvas.restore();
  }
}
