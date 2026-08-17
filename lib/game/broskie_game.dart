import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'player.dart';
import 'level_loader.dart';

class BroskieGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Player player;
  final WidgetRef ref;

  BroskieGame({required this.ref});

  @override
  Future<void> onLoad() async {
    add(ScreenHitbox());
    
    // Optimized Parallax
    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('skyline_far.png'),
        ParallaxImageData('skyline_near.png'),
      ],
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.5, 0),
    );
    add(parallax);

    player = Player(position: Vector2(100, 400));
    add(player);
    
    camera.follow(player);
    
    // We will now load level bytes from assets/levels/
    // Example: BinaryLevelLoader.loadFromBytes(this, bytes);
  }

  @override
  Color backgroundColor() => const Color(0xFF5C94FC); 
}

class Floor extends PositionComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  Floor(Vector2 position, Vector2 size) : super(position: position, size: size) {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = Colors.brown);
  }
}
