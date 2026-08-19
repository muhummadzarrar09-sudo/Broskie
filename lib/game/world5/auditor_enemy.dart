import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/world4/hater_cloud.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class AuditorEnemy extends SpriteAnimationComponent
    with HasGameReference<BroskieGame>, CollisionCallbacks {
  double attackTimer = 0;
  final double attackCooldown = 4.0;
  final double effectRange = 420;

  AuditorEnemy({required Vector2 position})
      : super(position: position, size: Vector2(48, 64)) {
    add(RectangleHitbox());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final image = await game.images.load('runtime/audit_drone.png');
      animation = SpriteAnimation.spriteList([Sprite(image)], stepTime: 1);
    } catch (_) {
      // Procedural auditor painter stays active without the art.
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    attackTimer += dt;

    if (attackTimer >= attackCooldown) {
      attackTimer = 0;
      _iceSpikeAttack();
    }
  }

  void _iceSpikeAttack() {
    // Frozen Assets: a real slow debuff when Broskie is in audit range.
    final player = game.children.whereType<Player>().firstOrNull;
    if (player == null) return;
    if ((player.position.x - position.x).abs() > effectRange) return;
    player.activeDebuffs.add(Debuff(DebuffType.slow, 2.0));
    BroskieAudio.playGlitch();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      other.hit();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    if (animation != null) {
      super.render(canvas);
      return;
    }

    final suitPaint = Paint()..color = const Color(0xFF006064);
    final icePaint = Paint()..color = Colors.cyanAccent;

    // Auditor Suit
    canvas.drawRect(const Rect.fromLTWH(8, 16, 32, 40), suitPaint);
    canvas.drawRect(
        const Rect.fromLTWH(12, 4, 24, 16), icePaint); // Frozen Head
    canvas.drawRect(const Rect.fromLTWH(16, 12, 16, 4),
        Paint()..color = Colors.white); // Sunglasses
  }
}
