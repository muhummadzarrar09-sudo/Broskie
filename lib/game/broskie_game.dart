import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import 'components/hazards.dart';
import 'components/world_components.dart';
import 'enemies/data_broker_boss.dart';
import 'enemies/enemy.dart';
import 'enemies/foreman_boss.dart';
import 'input/input_controller.dart';
import 'models/campaign_progress.dart';
import 'models/game_hud_state.dart';
import 'models/runtime_assets.dart';
import 'models/stage_catalog.dart';
import 'player.dart';
import 'services/campaign_repository.dart';

class BroskieGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  BroskieGame({CampaignRepository? campaignRepository})
    : _campaignRepository =
          campaignRepository ?? SharedPreferencesCampaignRepository(),
      super(
        camera: CameraComponent.withFixedResolution(
          width: logicalWidth,
          height: logicalHeight,
        ),
      );

  static const double logicalWidth = 960;
  static const double logicalHeight = 540;
  static const double groundY = 480;

  static const String hudOverlay = 'HUD';
  static const String menuOverlay = 'MainMenu';
  static const String stageIntroOverlay = 'StageIntro';
  static const String settingsOverlay = 'Settings';
  static const String creditsOverlay = 'Credits';
  static const String pauseOverlay = 'Pause';
  static const String gameOverOverlay = 'GameOver';
  static const String completeOverlay = 'LevelComplete';
  static const String endingOverlay = 'Ending';

  final CampaignRepository _campaignRepository;
  final InputController input = InputController();
  final ValueNotifier<GameHudState> hud = ValueNotifier(
    const GameHudState.initial(),
  );
  final ValueNotifier<CampaignProgress> campaign = ValueNotifier(
    const CampaignProgress(),
  );
  final List<SolidSurface> solids = [];
  final List<Vector2> _checkpoints = [];

  late Player player;
  late LevelExit exit;
  BossGate? bossGate;

  CampaignProgress progress = const CampaignProgress();
  GamePhase phase = GamePhase.menu;
  StageResult? lastResult;
  int currentStageIndex = 0;
  int health = 3;
  int cash = 0;
  int enemiesDefeated = 0;
  int bossHealth = 0;
  int bossMaxHealth = 1;
  double flow = 0;
  double stageTime = 0;

  Vector2 _checkpoint = Vector2(80, groundY - 58);
  bool _bossEncounterStarted = false;
  bool _transitioning = false;
  bool _gameReady = false;
  double _controlsHackTimer = 0;
  double _flowHoldTimer = 0;
  double _peakFlow = 0;
  double _hudTimer = 0;
  double _broadcastTimer = 0;
  int _tutorialStep = 0;
  String? _broadcastMessage;

  bool get isPlaying => phase == GamePhase.playing;
  bool get gameReady => _gameReady;
  bool get controlsInverted => _controlsHackTimer > 0;
  double get levelWidth => currentStage.levelWidth;
  StageInfo get currentStage => stages[currentStageIndex];
  bool get hapticsEnabled => progress.hapticsEnabled;
  bool get showTouchControls => progress.showTouchControls;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await images.loadAll(RuntimeAssets.all);
    progress = await _campaignRepository.load();
    campaign.value = progress;
    await _buildStage();
    camera.viewfinder.position = Vector2(logicalWidth / 2, logicalHeight / 2);
    phase = GamePhase.menu;
    _gameReady = true;
    campaign.value = progress;
    publishHud();
    pauseEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying || !player.isMounted) {
      return;
    }

    stageTime += dt;
    _controlsHackTimer = (_controlsHackTimer - dt).clamp(0.0, 10.0).toDouble();
    if (_flowHoldTimer > 0) {
      _flowHoldTimer -= dt;
    } else {
      flow = (flow - dt * 5).clamp(0.0, 100.0).toDouble();
    }
    if (_broadcastTimer > 0) {
      _broadcastTimer -= dt;
      if (_broadcastTimer <= 0) {
        _broadcastMessage = null;
      }
    }
    if (currentStageIndex == 0) {
      _updateTutorial();
    }

    final cameraX = player.center.x
        .clamp(logicalWidth / 2, levelWidth - logicalWidth / 2)
        .toDouble();
    camera.viewfinder.position.setValues(cameraX, logicalHeight / 2);

    for (final checkpoint in _checkpoints) {
      if (player.x >= checkpoint.x && checkpoint.x > _checkpoint.x) {
        _checkpoint = checkpoint;
      }
    }

    if (bossMaxHealth > 1 && player.x > levelWidth - 1450) {
      _bossEncounterStarted = true;
      if (bossHealth == 0 && !exit.unlocked) {
        bossHealth = bossMaxHealth;
      }
    }

    _hudTimer += dt;
    if (_hudTimer >= 0.1) {
      _hudTimer = 0;
      publishHud();
    }
  }

  void _updateTutorial() {
    if (_tutorialStep == 0) {
      _tutorialStep = 1;
      showBroadcast('MOVE WITH THE ARROWS. DASH WITH K OR THE YELLOW BUTTON.');
    } else if (_tutorialStep == 1 && player.x > 260) {
      _tutorialStep = 2;
      showBroadcast('JUMP WITH SPACE OR THE PINK BUTTON. KEEP YOUR MOMENTUM.');
    } else if (_tutorialStep == 2 && player.x > 720) {
      _tutorialStep = 3;
      showBroadcast('LAND ON CORPORATE CUBES. CHAINS BUILD FLOW AND SPEED.');
    }
  }

  Future<void> _buildStage() async {
    final components = <Component>[
      NeonCityBackdrop(
        levelSize: Vector2(levelWidth, logicalHeight),
        backgroundSprite: Sprite(
          images.fromCache(RuntimeAssets.backgroundForStage(currentStageIndex)),
        ),
        accent: currentStage.accent,
        reducedEffects: progress.reducedEffects,
      ),
    ];

    switch (currentStageIndex) {
      case 0:
        _buildGreyZone(components);
      case 1:
        _buildFactory(components);
      case 2:
        _buildNeonSlums(components);
      case 3:
        _buildMonopolyCore(components);
    }

    player = Player(position: Vector2(80, groundY - 58));
    components.addAll([exit, player]);
    await world.addAll(components);
  }

  void _buildGreyZone(List<Component> components) {
    const accent = Color(0xFF47F8FF);
    _ground(components, 0, 700, accent: accent);
    _ground(components, 780, 680, accent: accent);
    _ground(components, 1540, 660, accent: accent);
    _ground(components, 2280, levelWidth - 2280, accent: accent);
    _platform(components, 300, 398, 145, accent);
    _platform(components, 650, 350, 105, accent);
    _platform(components, 1040, 375, 190, accent);
    _platform(components, 1390, 315, 130, accent);
    _platform(components, 1880, 370, 190, accent);
    _addSurface(components, MysteryBlock(position: Vector2(520, 340)));
    _chips(components, [360, 675, 850, 1120, 1435, 1630, 1960, 2380, 2700]);
    components.addAll([
      GrumpyBrick(
        position: Vector2(410, groundY - 38),
        patrolStart: 360,
        patrolEnd: 640,
      ),
      GrumpyBrick(
        position: Vector2(1120, groundY - 38),
        patrolStart: 850,
        patrolEnd: 1370,
      ),
      GrumpyBrick(
        position: Vector2(1840, groundY - 38),
        patrolStart: 1600,
        patrolEnd: 2140,
      ),
      PropagandaTerminal(
        position: Vector2(2450, groundY - 72),
        message: 'HIJACK COMPLETE: THE DESIGNATED PATH IS MID.',
      ),
    ]);
    _checkpoints.addAll([
      Vector2(820, groundY - 58),
      Vector2(1580, groundY - 58),
      Vector2(2320, groundY - 58),
    ]);
    bossMaxHealth = 1;
    exit = LevelExit(position: Vector2(levelWidth - 120, groundY - 132))
      ..unlocked = true;
  }

  void _buildFactory(List<Component> components) {
    const accent = Color(0xFFFFB329);
    _ground(components, 0, 880, accent: accent);
    _ground(components, 960, 760, accent: accent);
    _ground(components, 1810, 650, accent: accent);
    _ground(components, 2540, levelWidth - 2540, accent: accent);
    for (var i = 0; i < 7; i++) {
      _platform(
        components,
        350.0 + i * 380.0,
        395.0 - (i.isOdd ? 75.0 : 0.0),
        145,
        accent,
      );
    }
    _addSurface(components, MysteryBlock(position: Vector2(1320, 330)));
    _chips(components, [390, 760, 1030, 1390, 1890, 2280, 2640, 3010]);
    components.addAll([
      GrumpyBrick(
        position: Vector2(560, groundY - 38),
        patrolStart: 300,
        patrolEnd: 820,
      ),
      GrumpyBrick(
        position: Vector2(1190, groundY - 38),
        patrolStart: 1000,
        patrolEnd: 1660,
      ),
      GrumpyBrick(
        position: Vector2(2050, groundY - 38),
        patrolStart: 1860,
        patrolEnd: 2390,
      ),
      TheForeman(
        position: Vector2(levelWidth - 820, groundY - 78),
        arenaLeft: levelWidth - 1200,
        arenaRight: levelWidth - 260,
      ),
    ]);
    _checkpoints.addAll([
      Vector2(1000, groundY - 58),
      Vector2(1860, groundY - 58),
      Vector2(2600, groundY - 58),
    ]);
    _lockBossExit(components, TheForeman.maxHealth);
  }

  void _buildNeonSlums(List<Component> components) {
    const accent = Color(0xFFFF3EC8);
    _ground(components, 0, 760, accent: accent);
    _ground(components, 850, 720, accent: accent);
    _ground(components, 1660, 780, accent: accent);
    _ground(components, 2530, 690, accent: accent);
    _ground(components, 3310, levelWidth - 3310, accent: accent);
    for (var i = 0; i < 8; i++) {
      _platform(
        components,
        280.0 + i * 430.0,
        400.0 - (i % 3) * 55.0,
        150,
        accent,
      );
    }
    _chips(components, [
      330,
      700,
      930,
      1320,
      1740,
      2150,
      2650,
      3050,
      3500,
      3890,
    ]);
    components.addAll([
      DataSpike(position: Vector2(600, groundY - 38), accent: accent),
      DataSpike(position: Vector2(1280, groundY - 38), accent: accent),
      DataSpike(position: Vector2(2050, groundY - 38), accent: accent),
      DataSpike(position: Vector2(2900, groundY - 38), accent: accent),
      HackZone(position: Vector2(1010, 240), size: Vector2(170, 240)),
      HackZone(position: Vector2(2700, 260), size: Vector2(190, 220)),
      PropagandaTerminal(
        position: Vector2(1850, groundY - 72),
        message: 'NETWORK NOTICE: UNAUTHORIZED VIBES DETECTED.',
      ),
      PropagandaTerminal(
        position: Vector2(3450, groundY - 72),
        message: 'BROSKIE: TERMS DECLINED. ALL OF THEM.',
      ),
      GrumpyBrick(
        position: Vector2(1100, groundY - 38),
        patrolStart: 900,
        patrolEnd: 1500,
      ),
      GrumpyBrick(
        position: Vector2(2300, groundY - 38),
        patrolStart: 1750,
        patrolEnd: 2380,
      ),
      GrumpyBrick(
        position: Vector2(3600, groundY - 38),
        patrolStart: 3380,
        patrolEnd: 4020,
      ),
    ]);
    _checkpoints.addAll([
      Vector2(900, groundY - 58),
      Vector2(1710, groundY - 58),
      Vector2(2580, groundY - 58),
      Vector2(3360, groundY - 58),
    ]);
    bossMaxHealth = 1;
    exit = LevelExit(position: Vector2(levelWidth - 120, groundY - 132))
      ..unlocked = true;
  }

  void _buildMonopolyCore(List<Component> components) {
    const accent = Color(0xFF55FF8A);
    _ground(components, 0, 820, accent: accent);
    _ground(components, 910, 700, accent: accent);
    _ground(components, 1700, 740, accent: accent);
    _ground(components, 2530, 720, accent: accent);
    _ground(components, 3340, levelWidth - 3340, accent: accent);
    for (var i = 0; i < 10; i++) {
      _platform(
        components,
        310.0 + i * 385.0,
        405.0 - (i % 4) * 48.0,
        138,
        accent,
      );
    }
    _addSurface(components, MysteryBlock(position: Vector2(2380, 310)));
    _chips(components, [
      350,
      720,
      980,
      1370,
      1780,
      2190,
      2640,
      3020,
      3480,
      3920,
    ]);
    components.addAll([
      DataSpike(position: Vector2(690, groundY - 38), accent: accent),
      DataSpike(position: Vector2(1450, groundY - 38), accent: accent),
      DataSpike(position: Vector2(2250, groundY - 38), accent: accent),
      DataSpike(position: Vector2(3100, groundY - 38), accent: accent),
      HackZone(position: Vector2(1200, 260), size: Vector2(180, 220)),
      HackZone(position: Vector2(2850, 250), size: Vector2(200, 230)),
      PropagandaTerminal(
        position: Vector2(3500, groundY - 72),
        message: 'FINAL UPLINK: EVERYONE, FIND YOUR OWN BEAT.',
      ),
      DataBrokerBoss(
        position: Vector2(levelWidth - 890, groundY - 105),
        arenaLeft: levelWidth - 1320,
        arenaRight: levelWidth - 270,
      ),
    ]);
    _checkpoints.addAll([
      Vector2(960, groundY - 58),
      Vector2(1760, groundY - 58),
      Vector2(2580, groundY - 58),
      Vector2(3400, groundY - 58),
    ]);
    _lockBossExit(components, DataBrokerBoss.maxHealth);
  }

  void _ground(
    List<Component> components,
    double x,
    double width, {
    required Color accent,
  }) {
    _addSurface(
      components,
      SolidSurface(
        position: Vector2(x, groundY),
        size: Vector2(width, 80),
        baseColor: Color.lerp(currentStage.skyBottom, Colors.black, 0.35)!,
        topColor: accent,
      ),
    );
  }

  void _platform(
    List<Component> components,
    double x,
    double y,
    double width,
    Color accent,
  ) {
    _addSurface(
      components,
      SolidSurface(
        position: Vector2(x, y),
        size: Vector2(width, 20),
        topColor: accent,
      ),
    );
  }

  void _addSurface(List<Component> components, SolidSurface surface) {
    solids.add(surface);
    components.add(surface);
  }

  void _chips(List<Component> components, List<double> xPositions) {
    components.addAll(
      xPositions.map((x) => CashChip(position: Vector2(x, groundY - 58))),
    );
  }

  void _lockBossExit(List<Component> components, int maxHealth) {
    bossMaxHealth = maxHealth;
    bossGate = BossGate(position: Vector2(levelWidth - 210, groundY - 190));
    _addSurface(components, bossGate!);
    exit = LevelExit(position: Vector2(levelWidth - 120, groundY - 132));
  }

  void startNewCampaign() {
    if (!_gameReady) {
      return;
    }
    progress = progress.copyWith(hasStarted: true, highestUnlockedStage: 0);
    campaign.value = progress;
    unawaited(_campaignRepository.save(progress));
    unawaited(prepareStage(0));
  }

  void continueCampaign() {
    if (_gameReady) {
      unawaited(prepareStage(progress.highestUnlockedStage));
    }
  }

  void selectStage(int index) {
    if (_gameReady && index <= progress.highestUnlockedStage) {
      unawaited(prepareStage(index));
    }
  }

  Future<void> prepareStage(int index) async {
    if (_transitioning || index < 0 || index >= stages.length) {
      return;
    }
    _transitioning = true;
    resumeEngine();
    input.reset();
    currentStageIndex = index;
    health = 3;
    cash = 0;
    enemiesDefeated = 0;
    bossHealth = 0;
    bossMaxHealth = 1;
    flow = 0;
    stageTime = 0;
    _peakFlow = 0;
    _flowHoldTimer = 0;
    _controlsHackTimer = 0;
    _broadcastMessage = null;
    _broadcastTimer = 0;
    _tutorialStep = 0;
    _bossEncounterStarted = false;
    _checkpoint = Vector2(80, groundY - 58);
    _checkpoints.clear();
    solids.clear();
    bossGate = null;
    world.removeAll(world.children.toList());
    await ready();
    await _buildStage();
    await ready();
    camera.viewfinder.position = Vector2(logicalWidth / 2, logicalHeight / 2);
    phase = GamePhase.stageIntro;
    overlays.clear();
    _addOverlay(hudOverlay);
    _addOverlay(stageIntroOverlay, priority: 10);
    publishHud();
    pauseEngine();
    _transitioning = false;
  }

  void beginStage() {
    if (phase != GamePhase.stageIntro) {
      return;
    }
    overlays.remove(stageIntroOverlay);
    phase = GamePhase.playing;
    stageTime = 0;
    publishHud();
    resumeEngine();
  }

  void setTouchLeft(bool pressed) => input.setTouchLeft(pressed);
  void setTouchRight(bool pressed) => input.setTouchRight(pressed);
  void jump() => input.queueJump();
  void dash() => input.queueDash();

  void spawnVoltCola(Vector2 position) {
    world.add(VoltCola(position: position));
  }

  void collectCash(int amount) {
    if (amount <= 0 || !isPlaying) {
      return;
    }
    cash += amount;
    addFlow(3);
    publishHud();
  }

  void addFlow(double amount) {
    if (amount <= 0) {
      return;
    }
    flow = (flow + amount).clamp(0.0, 100.0).toDouble();
    _peakFlow = _peakFlow < flow ? flow : _peakFlow;
    _flowHoldTimer = 2.2;
    publishHud();
  }

  void enemyDefeated() {
    enemiesDefeated++;
    addFlow(18);
  }

  void damagePlayer() {
    if (!isPlaying) {
      return;
    }
    health = (health - 1).clamp(0, 3).toInt();
    flow = (flow * 0.45).clamp(0.0, 100.0).toDouble();
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
    flow = 0;
    if (health == 0) {
      publishHud();
      _gameOver();
      return;
    }
    player.respawn(_checkpoint);
    publishHud();
  }

  void hackControls(double seconds) {
    _controlsHackTimer = _controlsHackTimer < seconds
        ? seconds
        : _controlsHackTimer;
    publishHud();
  }

  void showBroadcast(String message) {
    _broadcastMessage = message;
    _broadcastTimer = 4;
    publishHud();
  }

  void bossDamaged(int remainingHealth, int maxHealth) {
    bossMaxHealth = maxHealth;
    bossHealth = remainingHealth.clamp(0, maxHealth).toInt();
    publishHud();
  }

  void bossDefeated() {
    bossHealth = 0;
    cash += currentStageIndex == stages.length - 1 ? 2000 : 1200;
    enemiesDefeated++;
    exit.unlocked = true;
    final gate = bossGate;
    if (gate != null) {
      solids.remove(gate);
      gate.removeFromParent();
    }
    showBroadcast(
      currentStageIndex == stages.length - 1
          ? 'DATA BROKER DELETED. THE NETWORK IS OURS.'
          : 'MANAGEMENT REMOVED. EXIT AUTHORIZED.',
    );
    addFlow(35);
  }

  void completeLevel() {
    if (!isPlaying || !exit.unlocked) {
      return;
    }
    cash += 500;
    final targetTime = [75, 95, 110, 130][currentStageIndex];
    var rank = CampaignRank.c;
    if (health == 3 && stageTime <= targetTime && _peakFlow >= 80) {
      rank = CampaignRank.s;
    } else if (health >= 2 && stageTime <= targetTime * 1.25) {
      rank = CampaignRank.a;
    } else if (health >= 1 && stageTime <= targetTime * 1.7) {
      rank = CampaignRank.b;
    }
    lastResult = StageResult(
      cash: cash,
      enemiesDefeated: enemiesDefeated,
      elapsedSeconds: stageTime.round(),
      rank: rank,
    );

    final ranks = [...progress.bestRanks];
    if (rank.index > ranks[currentStageIndex]) {
      ranks[currentStageIndex] = rank.index;
    }
    final newlyUnlocked = (currentStageIndex + 1).clamp(0, 3).toInt();
    progress = progress.copyWith(
      hasStarted: true,
      highestUnlockedStage: progress.highestUnlockedStage > newlyUnlocked
          ? progress.highestUnlockedStage
          : newlyUnlocked,
      bestRanks: ranks,
    );
    campaign.value = progress;
    unawaited(_campaignRepository.save(progress));

    phase = GamePhase.stageComplete;
    input.reset();
    publishHud();
    _addOverlay(completeOverlay, priority: 10);
    pauseEngine();
  }

  void nextStage() {
    if (currentStageIndex == stages.length - 1) {
      overlays.remove(completeOverlay);
      phase = GamePhase.ending;
      publishHud();
      _addOverlay(endingOverlay, priority: 10);
      return;
    }
    unawaited(prepareStage(currentStageIndex + 1));
  }

  void _gameOver() {
    if (phase == GamePhase.gameOver) {
      return;
    }
    phase = GamePhase.gameOver;
    input.reset();
    publishHud();
    _addOverlay(gameOverOverlay, priority: 10);
    pauseEngine();
  }

  void togglePause() {
    if (phase == GamePhase.playing) {
      phase = GamePhase.paused;
      input.reset();
      publishHud();
      _addOverlay(pauseOverlay, priority: 10);
      pauseEngine();
    } else if (phase == GamePhase.paused) {
      overlays.remove(pauseOverlay);
      phase = GamePhase.playing;
      publishHud();
      resumeEngine();
    }
  }

  void restartStage() => unawaited(prepareStage(currentStageIndex));

  void showMenu() {
    input.reset();
    phase = GamePhase.menu;
    overlays.clear();
    _addOverlay(menuOverlay);
    publishHud();
    pauseEngine();
  }

  void _addOverlay(String name, {int priority = 0}) {
    if (overlays.registeredOverlays.contains(name)) {
      overlays.add(name, priority: priority);
    }
  }

  void openSettings() => _addOverlay(settingsOverlay, priority: 20);
  void closeSettings() => overlays.remove(settingsOverlay);
  void openCredits() => _addOverlay(creditsOverlay, priority: 20);
  void closeCredits() => overlays.remove(creditsOverlay);

  void setHaptics(bool enabled) {
    progress = progress.copyWith(hapticsEnabled: enabled);
    _saveSettings();
  }

  void setTouchControls(bool enabled) {
    progress = progress.copyWith(showTouchControls: enabled);
    input.reset();
    _saveSettings();
  }

  void setReducedEffects(bool enabled) {
    progress = progress.copyWith(reducedEffects: enabled);
    _saveSettings();
  }

  void _saveSettings() {
    campaign.value = progress;
    publishHud();
    unawaited(_campaignRepository.save(progress));
  }

  void publishHud() {
    final playerMounted = player.isMounted;
    final stageProgress = playerMounted
        ? (player.x / (levelWidth - player.width)).clamp(0.0, 1.0).toDouble()
        : 0.0;
    hud.value = GameHudState(
      health: health,
      cash: cash,
      progress: stageProgress,
      flow: flow,
      powered: playerMounted && player.powered,
      bossHealth: _bossEncounterStarted ? bossHealth : 0,
      bossMaxHealth: bossMaxHealth,
      stageNumber: currentStageIndex + 1,
      stageTitle: currentStage.title,
      elapsedSeconds: stageTime.round(),
      controlsInverted: controlsInverted,
      broadcast: _broadcastMessage,
      phase: phase,
    );
  }

  @override
  Color backgroundColor() => const Color(0xFF080B1F);

  @override
  void onRemove() {
    hud.dispose();
    campaign.dispose();
    super.onRemove();
  }
}
