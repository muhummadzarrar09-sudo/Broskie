import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'player.dart';
import 'blocks/interactable_block.dart';
import 'blocks/hazards.dart';
import 'enemies/enemy.dart';
import 'enemies/bull_enemy.dart';
import 'enemies/foreman_boss.dart';
import 'enemies/data_broker_boss.dart';
import 'levels/interactable_lore.dart';
import 'levels/level_exit.dart';
import 'world2/propaganda_sign.dart';
import 'world4/hater_cloud.dart';
import 'world5/auditor_enemy.dart';

class BroskieGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Player player;
  final WidgetRef ref;

  String activeSpeaker = 'BROSKIE CORP';
  String activeDialogue = '';
  int scoreCoins = 0;
  int enemiesDefeated = 0;
  bool isPaused = false;

  // Camera Shake Effect State
  double shakeIntensity = 0;

  BroskieGame({required this.ref});

  @override
  Future<void> onLoad() async {
    add(ScreenHitbox());

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
      add(ProceduralSkylineParallax());
    }

    _buildMassiveHardLevel();
  }

  @override
  void update(double dt) {
    if (shakeIntensity > 0) {
      shakeIntensity -= dt * 10;
      if (shakeIntensity < 0) shakeIntensity = 0;
      double offsetX = (Random().nextDouble() - 0.5) * shakeIntensity * 12;
      double offsetY = (Random().nextDouble() - 0.5) * shakeIntensity * 12;
      camera.snapTo(Vector2(player.position.x + offsetX, player.position.y + offsetY));
    }
    super.update(dt);
  }

  void triggerScreenShake({double intensity = 1.0}) {
    shakeIntensity = intensity;
  }

  void togglePause() {
    isPaused = !isPaused;
    if (isPaused) {
      pauseEngine();
      overlays.add('PauseMenu');
    } else {
      overlays.remove('PauseMenu');
      resumeEngine();
    }
  }

  void _buildMassiveHardLevel() {
    player = Player(position: Vector2(100, 300));
    add(player);
    camera.follow(player);

    // --- SECTOR 1: THE GREY ZONE ENTRY ---
    add(Floor(Vector2(-200, 480), Vector2(2200, 120)));

    add(InteractableBlock(position: Vector2(300, 340), type: BlockType.mystery));
    add(InteractableBlock(position: Vector2(332, 340), type: BlockType.brick));
    add(InteractableBlock(position: Vector2(364, 340), type: BlockType.mystery));

    add(InteractableLore(
      position: Vector2(180, 432),
      speaker: "BROSKIE CORP TERMINAL",
      text: "SYSTEM ALERT: Monopoly forces are restructuring Neo-City! Use 'J' or 'F' to throw Vinyl Boomerangs!",
    ));

    add(GrumpyBrick(position: Vector2(500, 448)));
    add(GrumpyBrick(position: Vector2(800, 448)));
    add(WallStreetBull(position: Vector2(1200, 432)));

    // --- SECTOR 2: THE LASER & MOVING PLATFORM PARKOUR RUN ---
    add(DataSpike(position: Vector2(2200, 480), size: Vector2(800, 32)));

    add(Floor(Vector2(2100, 360), Vector2(180, 24)));
    add(MovingPlatform(
      position: Vector2(2350, 320),
      size: Vector2(120, 24),
      targetPos: Vector2(2750, 320),
      speed: 140,
    ));

    add(Floor(Vector2(2900, 280), Vector2(200, 24)));
    add(LaserHazard(position: Vector2(3000, 160), size: Vector2(12, 120)));

    add(CrumblingPlatform(position: Vector2(3150, 280), size: Vector2(100, 24)));
    add(CrumblingPlatform(position: Vector2(3300, 280), size: Vector2(100, 24)));

    add(Floor(Vector2(3450, 340), Vector2(300, 24)));
    add(HaterCloud(position: Vector2(3500, 180)));
    add(AuditorEnemy(position: Vector2(3600, 276)));

    // Mid-Level Ground Floor
    add(Floor(Vector2(3800, 480), Vector2(2700, 120)));
    add(PropagandaSign(position: Vector2(4000, 416)));

    add(InteractableBlock(position: Vector2(4200, 340), type: BlockType.mystery));
    add(InteractableBlock(position: Vector2(4232, 340), type: BlockType.brick));
    add(InteractableBlock(position: Vector2(4264, 340), type: BlockType.mystery));

    add(WallStreetBull(position: Vector2(4500, 432)));
    add(GrumpyBrick(position: Vector2(4800, 448)));
    add(GrumpyBrick(position: Vector2(5100, 448)));

    // --- SECTOR 3: VERTICAL TOWER CLIMB ---
    add(DataSpike(position: Vector2(6500, 480), size: Vector2(1200, 32)));

    add(MovingPlatform(
      position: Vector2(6600, 400),
      size: Vector2(120, 24),
      targetPos: Vector2(6600, 180),
      speed: 120,
    ));

    add(Floor(Vector2(6800, 180), Vector2(200, 24)));
    add(LaserHazard(position: Vector2(6900, 60), size: Vector2(12, 120)));

    add(MovingPlatform(
      position: Vector2(7100, 180),
      size: Vector2(120, 24),
      targetPos: Vector2(7600, 180),
      speed: 180,
    ));

    add(Floor(Vector2(7800, 240), Vector2(250, 24)));
    add(AuditorEnemy(position: Vector2(7900, 176)));
    add(HaterCloud(position: Vector2(8000, 100)));

    // --- SECTOR 4: BOSS ARENA ---
    add(Floor(Vector2(8500, 480), Vector2(3500, 120)));

    add(InteractableLore(
      position: Vector2(8700, 432),
      speaker: "BROSKIE CORP TERMINAL",
      text: "WARNING: Entering High-Security Executive Arena! Restructuring Boss Ahead!",
    ));

    add(TheForeman(position: Vector2(9500, 384)));

    add(InteractableBlock(position: Vector2(10200, 340), type: BlockType.mystery));
    add(InteractableBlock(position: Vector2(10232, 340), type: BlockType.mystery));
    add(InteractableBlock(position: Vector2(10264, 340), type: BlockType.mystery));

    add(DataBrokerBoss(position: Vector2(10800, 400)));

    add(LevelExit(position: Vector2(11600, 352)));
  }

  void triggerGameOver() {
    triggerScreenShake(intensity: 1.5);
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
    overlays.remove('PauseMenu');
    overlays.remove('Shop');

    children.where((c) => c is! ScreenHitbox && c is! ProceduralSkylineParallax).toList().forEach((c) => c.removeFromParent());

    scoreCoins = 0;
    enemiesDefeated = 0;
    _buildMassiveHardLevel();
    resumeEngine();
  }

  @override
  Color backgroundColor() => const Color(0xFF0F0C20);
}

class Floor extends PositionComponent with HasGameRef<BroskieGame>, CollisionCallbacks {
  Floor(Vector2 position, Vector2 size) : super(position: position, size: size) {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final darkConcrete = Paint()..color = const Color(0xFF222533);
    final topNeonLine = Paint()..color = const Color(0xFF00E5FF);
    final gridLine = Paint()..color = const Color(0xFF33384A)..strokeWidth = 1;

    canvas.drawRect(rect, darkConcrete);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 4), topNeonLine);

    for (double x = 0; x < size.x; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridLine);
    }
    for (double y = 0; y < size.y; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridLine);
    }
  }
}

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
