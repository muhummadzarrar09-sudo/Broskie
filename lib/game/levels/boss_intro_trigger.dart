import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// Invisible tripwire that slaps the boss intro card on screen once.
class BossIntroTrigger extends PositionComponent with HasGameReference<BroskieGame>, CollisionCallbacks {
  final String bossName;
  final String bossTitle;
  final String bossArt;
  bool _fired = false;

  BossIntroTrigger({
    required Vector2 position,
    required this.bossName,
    required this.bossTitle,
    required this.bossArt,
  }) : super(position: position, size: Vector2(24, 200)) {
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !_fired) {
      _fired = true;
      gameRef.showBossCard(bossName, bossTitle, bossArt);
    }
    super.onCollision(intersectionPoints, other);
  }
}
