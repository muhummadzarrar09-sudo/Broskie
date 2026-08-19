import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum BlockType { brick, mystery, solid }

class InteractableBlock extends SpriteComponent with CollisionCallbacks {
  final BlockType type;
  bool isHit = false;

  InteractableBlock({required Vector2 position, required this.type})
      : super(position: position, size: Vector2(32, 32)) {
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !isHit) {
      final playerTop = other.position.y;
      final blockBottom = position.y + size.y;

      if (other.velocity.y < 0 &&
          playerTop <= blockBottom &&
          playerTop >= blockBottom - 12) {
        triggerBlock(other);
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  void triggerBlock(Player player) {
    if (type == BlockType.brick) {
      if (player.isBig) {
        BroskieAudio.playStomp();
        removeFromParent(); // Smash brick!
      } else {
        _bounceEffect();
      }
    } else if (type == BlockType.mystery) {
      isHit = true;
      BroskieAudio.playPowerup();
      _spawnItem(player);
      _bounceEffect();
    }
  }

  void _bounceEffect() {
    final originalY = position.y;
    position.y -= 8;
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      position.y = originalY;
    });
  }

  void _spawnItem(Player player) {
    final variants = [
      PowerUpType.classic,
      PowerUpType.juggernaut,
      PowerUpType.shockwave
    ];
    final selected = (variants..shuffle()).first;
    player.grow(selected);
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      super.render(canvas);
      return;
    }

    final rect = size.toRect();

    if (type == BlockType.mystery) {
      final bgPaint = Paint()
        ..color = isHit ? const Color(0xFF666666) : const Color(0xFFFFB300);
      final borderPaint = Paint()..color = const Color(0xFF8D6E63);
      final textPaint = TextPainter(
        text: TextSpan(
          text: isHit ? "•" : "?",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace'),
        ),
        textDirection: TextDirection.ltr,
      );

      canvas.drawRect(rect, bgPaint);
      canvas.drawRect(
          rect,
          Paint()
            ..color = borderPaint.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);

      textPaint.layout();
      textPaint.paint(
          canvas,
          Offset(
              (size.x - textPaint.width) / 2, (size.y - textPaint.height) / 2));
    } else if (type == BlockType.brick) {
      final brickPaint = Paint()..color = const Color(0xFFB23B00);
      final mortarPaint = Paint()
        ..color = const Color(0xFF5D1D00)
        ..strokeWidth = 1.5;

      canvas.drawRect(rect, brickPaint);
      canvas.drawRect(
          rect,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);

      // Brick mortar pattern
      canvas.drawLine(const Offset(0, 16), const Offset(32, 16), mortarPaint);
      canvas.drawLine(const Offset(16, 0), const Offset(16, 16), mortarPaint);
      canvas.drawLine(const Offset(8, 16), const Offset(8, 32), mortarPaint);
      canvas.drawLine(const Offset(24, 16), const Offset(24, 32), mortarPaint);
    } else {
      canvas.drawRect(rect, Paint()..color = const Color(0xFF424242));
    }
  }
}
