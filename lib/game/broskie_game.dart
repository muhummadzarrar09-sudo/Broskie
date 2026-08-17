import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'components/world_components.dart';
import 'enemies/enemy.dart';
import 'enemies/foreman_boss.dart';
import 'input/input_controller.dart';
import 'models/game_hud_state.dart';
import 'player.dart';

class BroskieGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  BroskieGame()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: logicalWidth,
          height: logicalHeight,
        ),
      );

  static const double logicalWidth = 960;
  static const double logicalHeight = 540;
  static const double levelWidth = 3660;
  static const double groundY = 480;

  static const String hudOverlay = 'HUD';
  static const String pauseOverlay = 'Pause';
  static const String gameOverOverlay = 'GameOver';
  static const String completeOverlay = 'LevelComplete';

  final InputController input = InputController();
  final ValueNotifier<GameHudState> hud = ValueNotifier(
    const GameHudState.initial(),
  );
  final List<SolidSurface> solids = [];

  late Player player;
  late LevelExit exit;
  late BossGate bossGate;

  GamePhase phase = GamePhase.playing;
  int health = 3;
  int cash = 0;
  int enemiesDefeated = 0;
  int bossHealth = 0;

  Vector2 _checkpoint = Vector2(80, groundY - 58);
  bool _bossEncounterStarted = false;
  bool _restarting = false;
  double _hudTimer = 0;

  bool get isPlaying => phase == GamePhase.playing;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _buildVerticalSlice();
    camera.viewfinder.position = Vector2(logicalWidth / 2, logicalHeight / 2);
    publishHud();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying || !player.isMounted) {
      return;
    }

    final cameraX = player.center.x
        .clamp(logicalWidth / 2, levelWidth - logicalWidth / 2)
        .toDouble();
    camera.viewfinder.position.setValues(cameraX, logicalHeight / 2);

    if (player.x > 2450 && !_bossEncounterStarted) {
      _bossEncounterStarted = true;
      bossHealth = TheForeman.maxHealth;
      publishHud();
    }

    if (player.x > 2460) {
      _checkpoint = Vector2(2510, groundY - player.height);
    } else if (player.x > 1740) {
      _checkpoint = Vector2(1810, groundY - player.height);
    } else if (player.x > 880) {
      _checkpoint = Vector2(940, groundY - player.height);
    }

    _hudTimer += dt;
    if (_hudTimer >= 0.1) {
      _hudTimer = 0;
      publishHud();
    }
  }

  Future<void> _buildVerticalSlice() async {
    final components = <Component>[
      NeonCityBackdrop(levelSize: Vector2(levelWidth, logicalHeight)),
    ];

    void addSurface(SolidSurface surface) {
      solids.add(surface);
      components.add(surface);
    }

    addSurface(
      SolidSurface(position: Vector2(0, groundY), size: Vector2(820, 80)),
    );
    addSurface(
      SolidSurface(position: Vector2(900, groundY), size: Vector2(780, 80)),
    );
    addSurface(
      SolidSurface(position: Vector2(1760, groundY), size: Vector2(670, 80)),
    );
    addSurface(
      SolidSurface(
        position: Vector2(2510, groundY),
        size: Vector2(levelWidth - 2510, 80),
        baseColor: const Color(0xFF35283F),
        topColor: const Color(0xFFFF3EC8),
      ),
    );

    addSurface(
      SolidSurface(position: Vector2(300, 398), size: Vector2(145, 20)),
    );
    addSurface(MysteryBlock(position: Vector2(575, 340)));
    addSurface(
      SolidSurface(position: Vector2(760, 405), size: Vector2(115, 20)),
    );
    addSurface(
      SolidSurface(
        position: Vector2(1110, 365),
        size: Vector2(190, 20),
        topColor: const Color(0xFFFFC83D),
      ),
    );
    addSurface(
      SolidSurface(
        position: Vector2(1470, 310),
        size: Vector2(150, 20),
        topColor: const Color(0xFFFFC83D),
      ),
    );
    addSurface(
      SolidSurface(position: Vector2(1640, 410), size: Vector2(155, 20)),
    );
    addSurface(
      SolidSurface(position: Vector2(1990, 375), size: Vector2(180, 20)),
    );
    addSurface(
      SolidSurface(position: Vector2(2280, 410), size: Vector2(175, 20)),
    );

    bossGate = BossGate(position: Vector2(3400, groundY - 190));
    addSurface(bossGate);
    exit = LevelExit(position: Vector2(3480, groundY - 132));

    player = Player(position: Vector2(80, groundY - 58));
    components.addAll([
      ...[
        Vector2(360, 345),
        Vector2(505, 425),
        Vector2(790, 355),
        Vector2(1020, 425),
        Vector2(1190, 310),
        Vector2(1515, 255),
        Vector2(1840, 420),
        Vector2(2055, 320),
        Vector2(2330, 355),
        Vector2(2620, 420),
      ].map((position) => CashChip(position: position)),
      GrumpyBrick(
        position: Vector2(500, groundY - 38),
        patrolStart: 460,
        patrolEnd: 760,
      ),
      GrumpyBrick(
        position: Vector2(1220, groundY - 38),
        patrolStart: 980,
        patrolEnd: 1600,
      ),
      GrumpyBrick(
        position: Vector2(2050, groundY - 38),
        patrolStart: 1810,
        patrolEnd: 2350,
      ),
      TheForeman(
        position: Vector2(2920, groundY - 78),
        arenaLeft: 2630,
        arenaRight: 3340,
      ),
      exit,
      player,
    ]);

    await world.addAll(components);
  }

  void setTouchLeft(bool pressed) => input.setTouchLeft(pressed);

  void setTouchRight(bool pressed) => input.setTouchRight(pressed);

  void jump() => input.queueJump();

  void collectCash(int amount) {
    if (amount <= 0 || !isPlaying) {
      return;
    }
    cash += amount;
    publishHud();
  }

  void enemyDefeated() {
    enemiesDefeated++;
    publishHud();
  }

  void damagePlayer() {
    if (!isPlaying) {
      return;
    }
    health = (health - 1).clamp(0, 3).toInt();
    publishHud();
    if (health == 0) {
      _gameOver();
    }
  }

  void playerFell() {
    if (!isPlaying) {
      return;
    }
    health = (health - 1).clamp(0, 3).toInt();
    if (health == 0) {
      publishHud();
      _gameOver();
      return;
    }
    player.respawn(_checkpoint);
    publishHud();
  }

  void bossDamaged(int remainingHealth) {
    bossHealth = remainingHealth.clamp(0, TheForeman.maxHealth).toInt();
    publishHud();
  }

  void bossDefeated() {
    bossHealth = 0;
    cash += 1000;
    enemiesDefeated++;
    exit.unlocked = true;
    solids.remove(bossGate);
    bossGate.removeFromParent();
    publishHud();
  }

  void completeLevel() {
    if (!isPlaying || !exit.unlocked) {
      return;
    }
    cash += 500;
    phase = GamePhase.complete;
    input.reset();
    publishHud();
    overlays.add(completeOverlay, priority: 10);
    pauseEngine();
  }

  void _gameOver() {
    if (phase == GamePhase.gameOver) {
      return;
    }
    phase = GamePhase.gameOver;
    input.reset();
    publishHud();
    overlays.add(gameOverOverlay, priority: 10);
    pauseEngine();
  }

  void togglePause() {
    if (phase == GamePhase.playing) {
      phase = GamePhase.paused;
      input.reset();
      publishHud();
      overlays.add(pauseOverlay, priority: 10);
      pauseEngine();
    } else if (phase == GamePhase.paused) {
      overlays.remove(pauseOverlay);
      phase = GamePhase.playing;
      publishHud();
      resumeEngine();
    }
  }

  Future<void> restart() async {
    if (_restarting) {
      return;
    }
    _restarting = true;
    overlays
      ..remove(gameOverOverlay)
      ..remove(completeOverlay)
      ..remove(pauseOverlay);
    resumeEngine();
    input.reset();
    phase = GamePhase.playing;
    health = 3;
    cash = 0;
    enemiesDefeated = 0;
    bossHealth = 0;
    _bossEncounterStarted = false;
    _checkpoint = Vector2(80, groundY - 58);
    solids.clear();
    world.removeAll(world.children.toList());
    await ready();
    await _buildVerticalSlice();
    await ready();
    camera.viewfinder.position = Vector2(logicalWidth / 2, logicalHeight / 2);
    publishHud();
    _restarting = false;
  }

  void restartUnawaited() => unawaited(restart());

  void publishHud() {
    final progress = player.isMounted
        ? (player.x / (levelWidth - player.width)).clamp(0.0, 1.0).toDouble()
        : 0.0;
    hud.value = GameHudState(
      health: health,
      cash: cash,
      progress: progress,
      powered: player.isMounted && player.powered,
      bossHealth: bossHealth,
      bossMaxHealth: TheForeman.maxHealth,
      phase: phase,
    );
  }

  @override
  Color backgroundColor() => const Color(0xFF080B1F);

  @override
  void onRemove() {
    hud.dispose();
    super.onRemove();
  }
}
