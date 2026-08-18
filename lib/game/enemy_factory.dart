import 'package:flame/components.dart';
import 'package:broskie_game/game/enemies/enemy.dart';

class EnemyPool {
  final List<GrumpyBrick> _pool = [];
  final int maxPoolSize = 20;

  GrumpyBrick acquire(Vector2 position) {
    if (_pool.isNotEmpty) {
      final enemy = _pool.removeLast();
      enemy.position.setFrom(position);
      enemy.isDead = false;
      return enemy;
    }
    return GrumpyBrick(position: position);
  }

  void release(GrumpyBrick enemy) {
    if (_pool.length < maxPoolSize) {
      enemy.removeFromParent();
      _pool.add(enemy);
    } else {
      enemy.removeFromParent();
    }
  }
}

class EnemyFactory {
  static final EnemyPool _cubePool = EnemyPool();

  static PositionComponent spawn(String type, Vector2 position) {
    switch (type) {
      case 'cube':
        return _cubePool.acquire(position);
      // Add other pools for other enemy types...
      default:
        return GrumpyBrick(position: position);
    }
  }

  static void recycle(Enemy enemy) {
    if (enemy is GrumpyBrick) {
      _cubePool.release(enemy);
    } else {
      enemy.removeFromParent();
    }
  }
}
