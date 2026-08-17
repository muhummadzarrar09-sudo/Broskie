import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../broskie_game.dart';
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
  int direction = -1;
  bool defeated = false;

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
    final body = Paint()..color = const Color(0xFFB84B3A);
    final mortar = Paint()
      ..color = const Color(0xFF641F2B)
      ..strokeWidth = 3;
    final dark = Paint()..color = const Color(0xFF17131F);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height - 5),
        const Radius.circular(4),
      ),
      body,
    );
    canvas.drawLine(Offset(0, 17), Offset(width, 17), mortar);
    canvas.drawLine(const Offset(19, 0), const Offset(19, 17), mortar);
    canvas.drawRect(const Rect.fromLTWH(7, 10, 7, 5), dark);
    canvas.drawRect(const Rect.fromLTWH(25, 10, 7, 5), dark);
    canvas.drawRect(const Rect.fromLTWH(12, 25, 15, 3), dark);
    canvas.drawRect(const Rect.fromLTWH(5, 33, 10, 5), dark);
    canvas.drawRect(const Rect.fromLTWH(24, 33, 10, 5), dark);
  }
}
