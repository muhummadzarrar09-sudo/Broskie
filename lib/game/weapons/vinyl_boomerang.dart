import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/effects/kill_burst.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/enemies/enemy.dart';
import 'package:broskie_game/game/enemies/foreman_boss.dart';
import 'package:broskie_game/game/enemies/data_broker_boss.dart';

class VinylBoomerang extends SpriteComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  final double speed = 400;
  bool returning = false;
  late Vector2 direction;
  late Player owner;
  double rotationAngle = 0;

  VinylBoomerang({required Vector2 position, required this.owner, required bool isLeft})
    : super(position: position, size: Vector2(24, 24)) {
    direction = isLeft ? Vector2(-1, 0) : Vector2(1, 0);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    rotationAngle += 15 * dt;

    if (!returning) {
      position += direction * speed * dt;
      if ((position - owner.position).length > 300) {
        returning = true;
      }
    } else {
      Vector2 toPlayer = (owner.position - position).normalized();
      position += toPlayer * speed * dt;

      if ((position - owner.position).length < 20) {
        removeFromParent();
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Enemy) {
      other.die();
      gameRef.add(KillBurst(position: other.position.clone()..add(other.size / 2)));
      gameRef.hitStop(0.05);
      removeFromParent();
    } else if (other is TheForeman) {
      other.hitByReflectedBrick();
      removeFromParent();
    } else if (other is DataBrokerBoss) {
      other.hit();
      removeFromParent();
    } else if (other is Player && returning) {
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(rotationAngle);

    canvas.drawCircle(Offset.zero, 12, Paint()..color = Colors.black); // Vinyl Record
    canvas.drawCircle(Offset.zero, 4, Paint()..color = Colors.magentaAccent); // Record Label
    canvas.drawCircle(Offset.zero, 1.5, Paint()..color = Colors.white); // Hole

    canvas.restore();
  }
}
