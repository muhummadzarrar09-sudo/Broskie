import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../broskie_game.dart';
import '../player.dart';

class DataSpike extends PositionComponent
    with CollisionCallbacks, HasGameReference<BroskieGame> {
  DataSpike({required super.position, this.accent = const Color(0xFFFF3EC8)})
    : super(size: Vector2(46, 38), priority: 5) {
    add(RectangleHitbox(position: Vector2(5, 8), size: Vector2(36, 30)));
  }

  final Color accent;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      other.takeHit(sourceDirection: x > other.x ? 1 : -1);
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = accent;
    final path = Path()
      ..moveTo(0, height)
      ..lineTo(11, 8)
      ..lineTo(20, height)
      ..lineTo(31, 3)
      ..lineTo(width, height)
      ..close();
    canvas.drawPath(path, paint);
  }
}

class HackZone extends PositionComponent
    with CollisionCallbacks, HasGameReference<BroskieGame> {
  HackZone({required super.position, required super.size})
    : super(priority: 1) {
    add(RectangleHitbox());
  }

  bool _armed = true;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (_armed && other is Player) {
      _armed = false;
      game.hackControls(3.5);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Player) {
      _armed = true;
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0x28FF3EC8)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    final scan = Paint()
      ..color = const Color(0x88FF3EC8)
      ..strokeWidth = 2;
    for (double y = 8; y < height; y += 14) {
      canvas.drawLine(Offset(0, y), Offset(width, y), scan);
    }
  }
}

class PropagandaTerminal extends PositionComponent
    with CollisionCallbacks, HasGameReference<BroskieGame> {
  PropagandaTerminal({required super.position, required this.message})
    : super(size: Vector2(66, 72), priority: 4) {
    add(RectangleHitbox());
  }

  final String message;
  bool hacked = false;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (!hacked && other is Player) {
      hacked = true;
      game.collectCash(200);
      game.addFlow(24);
      game.showBroadcast(message);
    }
  }

  @override
  void render(Canvas canvas) {
    final frame = hacked ? const Color(0xFF55FF8A) : const Color(0xFFFF3158);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = const Color(0xFF11172A),
    );
    canvas.drawRect(
      Rect.fromLTWH(4, 4, width - 8, 39),
      Paint()..color = frame.withValues(alpha: 0.28),
    );
    canvas.drawRect(
      Rect.fromLTWH(4, 4, width - 8, 39),
      Paint()
        ..color = frame
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final painter = TextPainter(
      text: TextSpan(
        text: hacked ? 'FREE' : 'OBEY',
        style: TextStyle(
          color: frame,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset((width - painter.width) / 2, 15));
    canvas.drawRect(
      Rect.fromLTWH(28, 43, 10, 29),
      Paint()..color = const Color(0xFF313D52),
    );
  }
}
