import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'player.dart';
import 'audio_manager.dart';
import 'stage_backdrop.dart';
import 'blocks/interactable_block.dart';
import 'blocks/hazards.dart';
import 'blocks/collectibles.dart';
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
  final WidgetRef? ref;

  // Live HUD state: overlays listen to these and rebuild on change.
  final ValueNotifier<int> currentStage = ValueNotifier(1); // 1..4
  final ValueNotifier<int> scoreCoins = ValueNotifier(0);
  final ValueNotifier<int> hp = ValueNotifier(maxHp);
  static const int maxHp = 3;

  String activeSpeaker = 'BROSKIE CORP';
  String activeDialogue = '';
  int enemiesDefeated = 0;
  bool isPaused = false;

  final Vector2 playerSpawn = Vector2(100, 300);
  double shakeIntensity = 0;

  BroskieGame({this.ref});

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
      parallax.priority = -100;
      add(parallax);
    } catch (e) {
      add(ProceduralSkylineParallax()..priority = -100);
    }

    _buildCurrentStage();
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

  /// Called by the LevelComplete overlay's NEXT LEVEL button.
  void advanceStage() {
    overlays.remove('LevelComplete');
    if (currentStage.value < 4) {
      currentStage.value++;
      restart();
    } else {
      pauseEngine();
      overlays.add('Victory');
    }
  }

  void _buildCurrentStage() {
    player = Player(position: playerSpawn.clone());
    add(player);
    camera.follow(player);

    if (currentStage.value == 1) {
      _buildStage1GreyZone();
    } else if (currentStage.value == 2) {
      _buildStage2NeonSlums();
    } else if (currentStage.value == 3) {
      _buildStage3StockExchange();
    } else {
      _buildStage4ExecutiveArena();
    }
  }

  void _buildStage1GreyZone() {
    add(StageBackdrop(imagePath: 'runtime/grey_zone_background.png', levelWidth: 2800));

    add(Floor(Vector2(-200, 480), Vector2(3000, 120)));
    add(InteractableBlock(position: Vector2(300, 340), type: BlockType.mystery));
    add(InteractableBlock(position: Vector2(332, 340), type: BlockType.brick));
    add(DataBitCoin(position: Vector2(500, 380)));
    add(DataBitCoin(position: Vector2(540, 380)));

    add(InteractableLore(
      position: Vector2(180, 432),
      speaker: "STAGE 1-1",
      text: "THE GREY ZONE: Run (SHIFT), jump (SPACE), dash (K) and throw Vinyl Boomerangs (J/F)!",
    ));

    add(GrumpyBrick(position: Vector2(800, 448), patrolRange: 300));
    add(GrumpyBrick(position: Vector2(1200, 448), patrolRange: 300));
    add(LevelExit(position: Vector2(2500, 352)));
  }

  void _buildStage2NeonSlums() {
    add(StageBackdrop(imagePath: 'runtime/neon_slums_background.png', levelWidth: 3500));

    add(Floor(Vector2(-200, 480), Vector2(1500, 120)));
    add(DataSpike(position: Vector2(1301, 480), size: Vector2(699, 32)));

    add(MovingPlatform(
      position: Vector2(1450, 320),
      size: Vector2(120, 24),
      targetPos: Vector2(1850, 320),
      speed: 160,
    ));

    add(Floor(Vector2(2000, 340), Vector2(1500, 120)));
    add(PropagandaSign(position: Vector2(2200, 276)));
    add(LaserHazard(position: Vector2(2500, 180), size: Vector2(12, 160)));
    add(HaterCloud(position: Vector2(2700, 180)));
    add(LevelExit(position: Vector2(3300, 212)));
  }

  void _buildStage3StockExchange() {
    add(StageBackdrop(imagePath: 'runtime/factory_background.png', levelWidth: 3200));

    add(Floor(Vector2(-200, 480), Vector2(1800, 120)));
    add(WallStreetBull(position: Vector2(800, 432), patrolRange: 280));
    add(WallStreetBull(position: Vector2(1400, 432), patrolRange: 150));

    add(DataSpike(position: Vector2(1601, 480), size: Vector2(998, 32)));

    add(MovingPlatform(
      position: Vector2(1700, 400),
      size: Vector2(120, 24),
      targetPos: Vector2(1700, 180),
      speed: 140,
    ));

    add(Floor(Vector2(1900, 180), Vector2(1200, 24)));
    add(AuditorEnemy(position: Vector2(2200, 116)));
    add(LevelExit(position: Vector2(2900, 52)));
  }

  void _buildStage4ExecutiveArena() {
    add(StageBackdrop(imagePath: 'runtime/monopoly_core_background.png', levelWidth: 3800));

    add(Floor(Vector2(-200, 480), Vector2(4000, 120)));

    add(InteractableLore(
      position: Vector2(180, 432),
      speaker: "FINAL STAGE",
      text: "EXECUTIVE ARENA: Bait the Foreman's charge into the arena walls, then stomp him. Burn the Data-Broker with boomerangs!",
    ));

    add(TheForeman(position: Vector2(900, 400), minX: 500, maxX: 1900));
    add(DataBrokerBoss(position: Vector2(2600, 406), minX: 2300, maxX: 3200));
    add(LevelExit(position: Vector2(3600, 352)));
  }

  /// Falling off the world costs one heart and respawns at the stage start.
  void onPlayerFell() {
    BroskieAudio.playHit();
    hp.value -= 1;
    if (hp.value <= 0) {
      triggerGameOver();
      return;
    }
    player.position.setFrom(playerSpawn);
    player.velocity.setZero();
    player.isInvulnerable = true;
    player.invulnerableTimer = 1.5;
    triggerScreenShake(intensity: 0.6);
  }

  void triggerGameOver() {
    triggerScreenShake(intensity: 1.5);
    pauseEngine();
    overlays.add('GameOver');
  }

  void triggerLevelComplete() {
    BroskieAudio.playStageComplete();
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
    overlays.remove('Victory');

    hp.value = maxHp;

    // Keep the persistent shell: hitbox + whatever sky was loaded in onLoad.
    // Everything else (player, stages, bosses, backdrops) is rebuilt fresh.
    children
        .where((c) => c is! ScreenHitbox && c is! ParallaxComponent && c is! ProceduralSkylineParallax)
        .toList()
        .forEach((c) => c.removeFromParent());

    _buildCurrentStage();
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
