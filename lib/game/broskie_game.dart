import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'player.dart';
import 'blocks/interactable_block.dart';
import 'enemies/enemy.dart';
import 'enemies/bull_enemy.dart';
import 'enemies/foreman_boss.dart';
import 'enemies/data_broker_boss.dart';
import 'levels/interactable_lore.dart';
import 'levels/level_exit.dart';
import 'world2/propaganda_sign.dart';
import 'world4/hater_cloud.dart';
import 'world5/auditor_enemy.dart';
import 'world7/falling_tower.dart';

class BroskieGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Player player;
  final WidgetRef ref;

  String activeSpeaker = 'BROSKIE CORP';
  String activeDialogue = '';
  int scoreCoins = 0;
  int enemiesDefeated = 0;

  BroskieGame({required this.ref});

  @override
  Future<void> onLoad() async {
    add(ScreenHitbox());

    // Safe Parallax Background Loading
    try {
      final parallax = await loadParallaxComponent(
        [
          ParallaxImageData('skyline_far.png'),
          ParallaxImageData('skyline_near.png'),
        ],
        baseVelocity: Vector2(20, 0),
        velocityMultiplierDelta: Vector2(1.5, 0),
      );
      add(parallax);
    } catch (e) {
      debugPrint("Parallax fallback activated: $e");
      add(ProceduralSkylineParallax());
    }

    _buildLevel();
  }

  void _buildLevel() {
    // 1. Spawning Player
    player = Player(position: Vector2(100, 300));
    add(player);
    camera.follow(player);

    // 2. Main Ground Floor
    add(Floor(Vector2(-200, 480), Vector2(3800, 120)));

    // 3. Platforms & Stepping Blocks
    add(Floor(Vector2(250, 360), Vector2(200, 24)));
    add(Floor(Vector2(550, 280), Vector2(180, 24)));
    add(Floor(Vector2(850, 360), Vector2(240, 24)));
    add(Floor(Vector2(1200, 260), Vector2(300, 24)));
    add(Floor(Vector2(1700, 340), Vector2(250, 24)));
    add(Floor(Vector2(2100, 280), Vector2(400, 24)));

    // 4. Mystery & Brick Blocks
    add(InteractableBlock(position: Vector2(300, 240), type: BlockType.mystery));
    add(InteractableBlock(position: Vector2(332, 240), type: BlockType.brick));
    add(InteractableBlock(position: Vector2(364, 240), type: BlockType.mystery));
    add(InteractableBlock(position: Vector2(600, 160), type: BlockType.mystery));
    add(InteractableBlock(position: Vector2(900, 220), type: BlockType.brick));
    add(InteractableBlock(position: Vector2(1250, 140), type: BlockType.mystery));

    // 5. Enemies & Bosses
    add(GrumpyBrick(position: Vector2(400, 448)));
    add(GrumpyBrick(position: Vector2(650, 248)));
    add(WallStreetBull(position: Vector2(1000, 432)));
    add(HaterCloud(position: Vector2(1300, 180)));
    add(AuditorEnemy(position: Vector2(1750, 276)));
    add(TheForeman(position: Vector2(2300, 384))); // World 1 Boss

    // 6. Interactive Cyberpunk Sign & Lore Terminals
    add(PropagandaSign(position: Vector2(500, 416)));
    add(InteractableLore(
      position: Vector2(180, 432),
      speaker: "BROSKIE CORP TERMINAL",
      text: "SYSTEM ALERT: Monopoly forces are restructuring Neo-City! Find the Volt-Cola and break the standardization!",
    ));

    // 7. Level Exit Portal
    add(LevelExit(position: Vector2(3200, 352)));
  }

  void triggerGameOver() {
    pauseEngine();
    overlays.add('GameOver');
  }

  void triggerLevelComplete() {
    pauseEngine();
    overlays.add('LevelComplete');
  }

  void showDialogue(String speaker, String text) {
    activeSpeaker = speaker;
    activeDialogue = text;
    overlays.add('Dialogue');
  }

  void hideDialogue() {
    overlays.remove('Dialogue');
  }

  void restart() {
    overlays.remove('GameOver');
    overlays.remove('LevelComplete');
    overlays.remove('Dialogue');

    // Clear all components except camera/hitbox
    children.where((c) => c is! ScreenHitbox && c is! ProceduralSkylineParallax).toList().forEach((c) => c.removeFromParent());

    scoreCoins = 0;
    enemiesDefeated = 0;
    _buildLevel();
    resumeEngine();
  }

  @override
  Color backgroundColor() => const Color(0xFF0F0C20); // Deep Cyberpunk Purple/Blue
}

// Floor Class with Retro Concrete/Brick Styling
class Floor extends PositionComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  Floor(Vector2 position, Vector2 size) : super(position: position, size: size) {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final darkConcrete = Paint()..color = const Color(0xFF222533);
    final topNeonLine = Paint()..color = const Color(0xFF00E5FF); // Neon Cyan top highlight
    final gridLine = Paint()..color = const Color(0xFF33384A)..strokeWidth = 1;

    canvas.drawRect(rect, darkConcrete);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 4), topNeonLine);

    // Brick grid pattern
    for (double x = 0; x < size.x; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridLine);
    }
    for (double y = 0; y < size.y; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridLine);
    }
  }
}

// Fallback Parallax in case image files missing
class ProceduralSkylineParallax extends Component with HasGameRef<BroskieGame> {
  double scrollX = 0;

  @override
  void update(double dt) {
    scrollX += 20 * dt;
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    final skyPaint = Paint()..color = const Color(0xFF140D2B);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), skyPaint);

    final bldgPaintFar = Paint()..color = const Color(0xFF211442);
    for (double x = -100; x < size.x + 200; x += 80) {
      double drawX = (x - scrollX * 0.3) % (size.x + 200) - 100;
      canvas.drawRect(Rect.fromLTWH(drawX, size.y - 250, 70, 250), bldgPaintFar);
    }

    final bldgPaintNear = Paint()..color = const Color(0xFF2E195E);
    for (double x = -100; x < size.x + 200; x += 120) {
      double drawX = (x - scrollX * 0.7) % (size.x + 200) - 100;
      canvas.drawRect(Rect.fromLTWH(drawX, size.y - 180, 100, 180), bldgPaintNear);
    }
  }
}
