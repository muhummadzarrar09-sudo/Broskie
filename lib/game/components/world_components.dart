import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../broskie_game.dart';
import '../player.dart';

class NeonCityBackdrop extends PositionComponent
    with HasGameReference<BroskieGame> {
  NeonCityBackdrop({
    required Vector2 levelSize,
    required this.backgroundSprite,
    required this.accent,
    required this.reducedEffects,
  }) : super(size: levelSize, priority: -100);

  static const double panelWidth = 960;

  final Sprite backgroundSprite;
  final Color accent;
  final bool reducedEffects;

  @override
  void render(Canvas canvas) {
    final visible = game.camera.visibleWorldRect;
    final maxPanel = math.max(0, (width / panelWidth).ceil() - 1);
    final firstPanel = (visible.left / panelWidth)
        .floor()
        .clamp(0, maxPanel)
        .toInt();
    final lastPanel = (visible.right / panelWidth)
        .floor()
        .clamp(firstPanel, maxPanel)
        .toInt();
    final panelSize = Vector2(panelWidth, height);
    for (var panel = firstPanel; panel <= lastPanel; panel++) {
      final x = panel * panelWidth;
      canvas.save();
      if (panel.isOdd) {
        canvas.translate(x + panelWidth, 0);
        canvas.scale(-1, 1);
        backgroundSprite.render(canvas, size: panelSize);
      } else {
        backgroundSprite.render(
          canvas,
          position: Vector2(x, 0),
          size: panelSize,
        );
      }
      canvas.restore();
    }

    final visibleBounds = Rect.fromLTWH(visible.left, 0, visible.width, height);
    canvas.drawRect(
      visibleBounds,
      Paint()
        ..color = Colors.black.withValues(alpha: reducedEffects ? 0.22 : 0.1),
    );

    final gridPaint = Paint()
      ..color = accent.withValues(alpha: reducedEffects ? 0.025 : 0.055)
      ..strokeWidth = 1;
    final firstGridLine = (visible.left / 64).floor() * 64.0;
    for (double x = firstGridLine; x <= visible.right + 64; x += 64) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }
  }
}

class SolidSurface extends PositionComponent
    with HasGameReference<BroskieGame> {
  SolidSurface({
    required super.position,
    required super.size,
    this.baseColor = const Color(0xFF27354A),
    this.topColor = const Color(0xFF43F4FF),
    super.priority = 0,
  });

  final Color baseColor;
  final Color topColor;

  Rect get collisionBounds => Rect.fromLTWH(x, y, width, height);

  void onHeadBump(Player player) {}

  @override
  void render(Canvas canvas) {
    final bounds = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(bounds, Paint()..color = baseColor);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, math.min(6.0, height)),
      Paint()..color = topColor,
    );

    final seamPaint = Paint()
      ..color = const Color(0x55101826)
      ..strokeWidth = 2;
    for (double offset = 32; offset < width; offset += 32) {
      canvas.drawLine(Offset(offset, 6), Offset(offset, height), seamPaint);
    }
  }
}

class MysteryBlock extends SolidSurface {
  MysteryBlock({required super.position})
    : super(
        size: Vector2.all(44),
        baseColor: const Color(0xFFFFB51B),
        topColor: const Color(0xFFFFF06A),
        priority: 2,
      );

  bool used = false;

  @override
  void onHeadBump(Player player) {
    if (used) {
      return;
    }
    used = true;
    game.spawnVoltCola(Vector2(x + 2, y - 48));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final textPainter = TextPainter(
      text: TextSpan(
        text: used ? '✓' : '?',
        style: TextStyle(
          color: used ? const Color(0xFF626A76) : const Color(0xFF151323),
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset((width - textPainter.width) / 2, 7));
  }
}

class CashChip extends PositionComponent
    with CollisionCallbacks, HasGameReference<BroskieGame> {
  CashChip({required super.position})
    : super(size: Vector2(26, 26), priority: 5) {
    add(CircleHitbox());
  }

  double _time = 0;
  late final double _originY = y;

  @override
  void update(double dt) {
    _time += dt;
    y = _originY + math.sin(_time * 3.5) * 5;
    angle += dt * 1.8;
    super.update(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player && !isRemoving) {
      game.collectCash(100);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      width / 2,
      Paint()..color = const Color(0xFF72FF73),
    );
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      width / 2 - 4,
      Paint()
        ..color = const Color(0xFF092D23)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(width / 2, height / 2),
        width: 4,
        height: 13,
      ),
      Paint()..color = const Color(0xFF092D23),
    );
  }
}

class VoltCola extends PositionComponent
    with CollisionCallbacks, HasGameReference<BroskieGame> {
  VoltCola({required super.position})
    : super(size: Vector2(38, 46), priority: 6) {
    add(RectangleHitbox());
  }

  double _time = 0;
  late final double _originY = y;

  @override
  void update(double dt) {
    _time += dt;
    y = _originY + math.sin(_time * 4) * 4;
    super.update(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player && !isRemoving) {
      other.activateVoltCola();
      game.collectCash(250);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final glow = Paint()..color = const Color(0x3347F8FF);
    canvas.drawCircle(Offset(width / 2, height / 2), 27, glow);
    final can = RRect.fromRectAndRadius(
      Rect.fromLTWH(7, 2, 24, 42),
      const Radius.circular(5),
    );
    canvas.drawRRect(can, Paint()..color = const Color(0xFF18C9F3));
    canvas.drawRect(
      const Rect.fromLTWH(9, 4, 20, 5),
      Paint()..color = const Color(0xFFE7F7FF),
    );
    final bolt = Path()
      ..moveTo(20, 11)
      ..lineTo(13, 26)
      ..lineTo(19, 26)
      ..lineTo(15, 38)
      ..lineTo(27, 21)
      ..lineTo(21, 21)
      ..close();
    canvas.drawPath(bolt, Paint()..color = const Color(0xFFFFEC39));
  }
}

class BossGate extends SolidSurface {
  BossGate({required super.position})
    : super(
        size: Vector2(30, 190),
        baseColor: const Color(0xFF45133D),
        topColor: const Color(0xFFFF3EC8),
        priority: 3,
      );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final laser = Paint()
      ..color = const Color(0xAAFF3EC8)
      ..strokeWidth = 4;
    for (double y = 12; y < height; y += 20) {
      canvas.drawLine(Offset(2, y), Offset(width - 2, y), laser);
    }
  }
}

class LevelExit extends PositionComponent
    with CollisionCallbacks, HasGameReference<BroskieGame> {
  LevelExit({required super.position})
    : super(size: Vector2(82, 132), priority: 4) {
    add(RectangleHitbox());
  }

  bool unlocked = false;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (unlocked && other is Player) {
      game.completeLevel();
    }
  }

  @override
  void render(Canvas canvas) {
    final color = unlocked ? const Color(0xFF42FFB3) : const Color(0xFFFF3E72);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        const Radius.circular(10),
      ),
      Paint()
        ..color = const Color(0xFF08141D)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 3, width - 6, height - 6),
        const Radius.circular(8),
      ),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.drawCircle(
      Offset(width - 17, height / 2),
      6,
      Paint()..color = color,
    );

    final painter = TextPainter(
      text: TextSpan(
        text: unlocked ? 'EXIT' : 'LOCKED',
        style: TextStyle(
          color: color,
          fontSize: unlocked ? 17 : 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset((width - painter.width) / 2, 16));
  }
}
