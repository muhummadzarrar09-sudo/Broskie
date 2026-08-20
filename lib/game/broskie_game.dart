import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_manager.dart';
import 'blocks/checkpoint.dart';
import 'blocks/collectibles.dart';
import 'blocks/hazards.dart';
import 'blocks/interactable_block.dart';
import 'difficulty.dart';
import 'enemies/bull_enemy.dart';
import 'enemies/data_broker_boss.dart';
import 'enemies/enemy.dart';
import 'enemies/foreman_boss.dart';
import 'haptics.dart';
import 'levels/boss_intro_trigger.dart';
import 'levels/interactable_lore.dart';
import 'levels/level_exit.dart';
import 'player.dart';
import 'stage_backdrop.dart';
import 'world2/propaganda_sign.dart';
import 'world4/hater_cloud.dart';
import 'world5/auditor_enemy.dart';

class BroskieGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Player player;

  // Live HUD state: overlays listen to these and rebuild on change.
  final ValueNotifier<int> currentStage = ValueNotifier(1); // 1..4
  final ValueNotifier<int> scoreCoins = ValueNotifier(0);
  final ValueNotifier<int> hp = ValueNotifier(3);
  /// Normal-mode hearts. Rank math and older tests use this constant.
  static const int maxHp = 3;
  final ValueNotifier<BroskieDifficulty> difficulty =
      ValueNotifier(BroskieDifficulty.normal);
  int get hpMax => difficulty.value.hearts;

  // Crew settings + campaign progression (persisted on-device).
  final ValueNotifier<int> unlockedStage = ValueNotifier(1);
  final ValueNotifier<bool> sfxEnabled = ValueNotifier(true);
  final ValueNotifier<bool> musicEnabled = ValueNotifier(true);
  final ValueNotifier<bool> touchControlsEnabled = ValueNotifier(true);
  final ValueNotifier<bool> hapticsEnabled = ValueNotifier(true);
  final ValueNotifier<double> shakeScale = ValueNotifier(1.0);
  final ValueNotifier<double> sfxVolume = ValueNotifier(1.0);
  final ValueNotifier<double> musicVolume = ValueNotifier(1.0);
  static const int saveVersion = 1;

  String activeSpeaker = 'BROSKIE CORP';
  String activeDialogue = '';
  int enemiesDefeated = 0;
  bool isPaused = false;
  /// One airborne mistake cannot tax HP twice (spike + abyss).
  bool fallTaxed = false;

  // Stage performance tracking for ranks + persistence.
  double stageTime = 0;
  String lastRank = 'C';
  final Map<int, int> bestRanks = {}; // stage -> 1=C, 2=B, 3=A, 4=S

  // Juice state.
  double _hitStopTimer = 0;

  // Boss intro card state (read by the BossCard overlay).
  String bossCardName = '';
  String bossCardTitle = '';
  String bossCardArt = '';

  // Stage presentation registry (read by the StageBanner overlay).
  static const Map<int, (String, String)> stageInfo = {
    1: ('THE GREY ZONE', 'UNAUTHORIZED INDIVIDUALITY'),
    2: ('NEON SLUMS', 'TERMS AND CONDITIONS APPLY'),
    3: ('THE EXCHANGE', 'MARKET HOSTILITY'),
    4: ('EXECUTIVE ARENA', 'GOING LIVE'),
  };
  static const Map<int, int> stageAccents = {
    1: 0xFF00E5FF,
    2: 0xFFFF3FA4,
    3: 0xFFF2F2F2,
    4: 0xFFFFB800,
  };

  /// The world dances to its own chiptune: sharp 0..1 spike on every beat.
  static const Map<int, int> stageBpm = {1: 92, 2: 112, 3: 128, 4: 140};
  double get beatPulse {
    final bpm = stageBpm[currentStage.value] ?? 100;
    final phase = (stageTime * bpm / 60) % 1.0;
    final t = 1 - phase;
    return t * t;
  }

  /// 60-90ms freeze frame — this is why actions feel expensive.
  void hitStop([double seconds = 0.07]) {
    _hitStopTimer = max(_hitStopTimer, seconds);
  }

  void showBossCard(String name, String title, String artFile) {
    bossCardName = name;
    bossCardTitle = title;
    bossCardArt = artFile;
    BroskieAudio.playGlitch();
    triggerScreenShake(intensity: 0.5);
    if (hapticsEnabled.value) BroskieHaptics.medium();
    _showOverlay('BossCard');
  }

  void hideBossCard() {
    _hideOverlay('BossCard');
  }

  /// When true, every overlay request becomes a no-op. Unit tests run the
  /// game headless — no GameWidget, so no overlay builders are registered and
  /// Flame would assert on add. Production leaves this off.
  bool overlaysMuted = false;

  static const Set<String> _blockingOverlays = {
    'PauseMenu',
    'Settings',
    'Shop',
    'LevelSelect',
    'Dialogue',
    'GameOver',
    'LevelComplete',
    'Victory',
    'MainMenu',
    'BossCard',
    'StageLoad',
    'DeathCard',
  };

  void _showOverlay(String name) {
    if (overlaysMuted) return;
    overlays.add(name);
    _syncEnginePause();
  }

  void _hideOverlay(String name) {
    if (overlaysMuted) return;
    overlays.remove(name);
    _syncEnginePause();
  }

  void _syncEnginePause() {
    if (overlaysMuted) return;
    final block = _blockingOverlays.any(overlays.isActive);
    if (block) {
      pauseEngine();
    } else {
      isPaused = false;
      resumeEngine();
    }
  }

  void openSettings() => _showOverlay('Settings');
  void openLevelSelect() => _showOverlay('LevelSelect');
  void openShop() => _showOverlay('Shop');
  void dismissOverlay(String name) => _hideOverlay(name);

  void returnToTitle() {
    isPaused = false;
    _hideOverlay('PauseMenu');
    _hideOverlay('Shop');
    _hideOverlay('Settings');
    _hideOverlay('LevelSelect');
    _hideOverlay('Dialogue');
    _hideOverlay('GameOver');
    _hideOverlay('LevelComplete');
    _hideOverlay('Victory');
    _hideOverlay('BossCard');
    _hideOverlay('StageBanner');
    _hideOverlay('StageLoad');
    _hideOverlay('DeathCard');
    hideBossBar();
    _showOverlay('MainMenu');
    BroskieAudio.startMusic();
  }

  void noteAirHit() => fallTaxed = true;
  void clearFallTax() => fallTaxed = false;

  void hideStageBanner() {
    _hideOverlay('StageBanner');
  }

  void finishStageLoad() => _hideOverlay('StageLoad');
  void hideDeathCard() => _hideOverlay('DeathCard');

  // ——— Boss HUD nameplate bar (fighting-game style) ———
  final ValueNotifier<double> bossBar = ValueNotifier(-1); // < 0 = hidden
  String bossBarName = '';

  void showBossBar(String name) {
    bossBarName = name;
    bossBar.value = 1;
    _showOverlay('BossBar');
  }

  void updateBossBar(double fraction) {
    bossBar.value = fraction.clamp(0.0, 1.0);
  }

  void hideBossBar() {
    _hideOverlay('BossBar');
    bossBar.value = -1;
  }

  // ——— Screen flash: the white frame on the killing blow ———
  final ValueNotifier<double> screenFlash = ValueNotifier(0);

  void triggerScreenFlash([double peak = 0.85]) {
    screenFlash.value = peak;
  }

  final Vector2 playerSpawn = Vector2(100, 300);
  double shakeIntensity = 0;

  /// Mario framing: a 16:9 window on the street. Ground sits in the lower
  /// third; Broskie is NOT centered. See `_updateMarioCamera`.
  static const double viewW = 640;
  static const double viewH = 360;
  static const double streetY = 480;
  static const double camLockY = 380;
  static const double lookAhead = 110;
  double _levelWidth = 2800;
  bool _brokerReleased = false;

  BroskieGame();

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.visibleGameSize = Vector2(viewW, viewH);

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

    // Hold the world behind the main menu until the crew hits RUN IT.
    pauseEngine();
  }

  static final Random _shakeRng = Random();

  @override
  void update(double dt) {
    // Hitch guard: a 200ms stall must not tunnel the 120px floor.
    if (dt > 1 / 20) dt = 1 / 20;
    // Hit-stop window: only the frozen share of dt is consumed; the spill
    // rolls into the world on the frame the freeze burns through.
    if (_hitStopTimer > 0) {
      _hitStopTimer -= dt;
      if (_hitStopTimer > 0) return; // still frozen solid
      dt = -_hitStopTimer; // thawed mid-frame: pass the unfrozen slice down
      _hitStopTimer = 0;
    }
    stageTime += dt;
    if (screenFlash.value > 0) {
      screenFlash.value = (screenFlash.value - dt * 2.2).clamp(0.0, 1.0);
    }
    super.update(dt);
    _maybeReleaseBroker();
    _updateMarioCamera();
    if (shakeIntensity > 0) {
      shakeIntensity -= dt * 10;
      if (shakeIntensity < 0) shakeIntensity = 0;
      final offsetX = (_shakeRng.nextDouble() - 0.5) * shakeIntensity * 12;
      final offsetY = (_shakeRng.nextDouble() - 0.5) * shakeIntensity * 8;
      camera.viewfinder.position.add(Vector2(offsetX, offsetY));
    }
  }

  /// SMB-style rig: follow X with look-ahead, lock Y so the street lives in
  /// the lower third. Climbing (stage 3 tower) slides Y just enough to keep
  /// Broskie in that same lower-middle band.
  void _updateMarioCamera() {
    if (!player.isMounted) return;
    final px = player.position.x + player.size.x / 2;
    final feet = player.position.y + player.size.y;
    var targetY = camLockY;
    if (feet < streetY - 70) {
      targetY = feet - viewH * 0.62;
    }
    final targetX = px + player.facing * lookAhead;
    final halfW = viewW / 2;
    final minX = halfW - 80;
    final maxX = max(minX, _levelWidth - halfW);
    camera.viewfinder.position = Vector2(
      targetX.clamp(minX, maxX),
      targetY,
    );
  }

  void triggerScreenShake({double intensity = 1.0}) {
    shakeIntensity = intensity * shakeScale.value;
  }

  // ── Stage ranks (crew bragging rights) ─────────────────────────────────
  static const Map<int, double> parTimes = {1: 35, 2: 50, 3: 55, 4: 110};

  static String stageRankFor(int stage, int hearts, double seconds,
      {int maxHearts = maxHp}) {
    final par = parTimes[stage] ?? 60;
    if (hearts >= maxHearts && seconds <= par) return 'S';
    if (hearts >= 2 && seconds <= par * 1.5) return 'A';
    if (seconds <= par * 2 || hearts >= 2) return 'B';
    return 'C';
  }

  static int rankValue(String rank) => switch (rank) {
        'S' => 4,
        'A' => 3,
        'B' => 2,
        _ => 1,
      };

  static String rankLabel(int value) => switch (value) {
        4 => 'S',
        3 => 'A',
        2 => 'B',
        1 => 'C',
        _ => '—',
      };

  String bestRankLabelFor(int stage) => rankLabel(bestRanks[stage] ?? 0);

  /// Persist settings + campaign progress locally. Crew build: no accounts,
  /// no servers — the save lives on the device.
  Future<void> loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      sfxEnabled.value = prefs.getBool('settings_sfx') ?? true;
      musicEnabled.value = prefs.getBool('settings_music') ?? true;
      touchControlsEnabled.value = prefs.getBool('settings_touch') ?? true;
      hapticsEnabled.value = prefs.getBool('settings_haptics') ?? true;
      shakeScale.value = prefs.getDouble('settings_shake') ?? 1.0;
      sfxVolume.value = prefs.getDouble('settings_sfx_vol') ?? 1.0;
      musicVolume.value = prefs.getDouble('settings_music_vol') ?? 1.0;
      BroskieAudio.setSfxVolume(sfxVolume.value);
      BroskieAudio.setMusicVolume(musicVolume.value);
      difficulty.value = BroskieDifficulty.fromName(
          prefs.getString('settings_difficulty'));
      unlockedStage.value = max(1, min(4, prefs.getInt('unlocked_stage') ?? 1));
      scoreCoins.value = max(0, prefs.getInt('wallet') ?? 0);
      for (var i = 1; i <= 4; i++) {
        bestRanks[i] = prefs.getInt('rank_stage_$i') ?? 0;
      }
      BroskieAudio.setSfx(sfxEnabled.value);
      BroskieAudio.setMusicEnabled(musicEnabled.value);
    } catch (_) {}
  }

  Future<void> savePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('settings_sfx', sfxEnabled.value);
      await prefs.setBool('settings_music', musicEnabled.value);
      await prefs.setBool('settings_touch', touchControlsEnabled.value);
      await prefs.setBool('settings_haptics', hapticsEnabled.value);
      await prefs.setDouble('settings_shake', shakeScale.value);
      await prefs.setDouble('settings_sfx_vol', sfxVolume.value);
      await prefs.setDouble('settings_music_vol', musicVolume.value);
      await prefs.setInt('save_v', saveVersion);
      await prefs.setString('settings_difficulty', difficulty.value.name);
      await prefs.setInt('unlocked_stage', unlockedStage.value);
      await prefs.setInt('wallet', scoreCoins.value);
      for (final entry in bestRanks.entries) {
        await prefs.setInt('rank_stage_${entry.key}', entry.value);
      }
    } catch (_) {}
  }

  /// A checkpoint flag was touched: falls now respawn at the ground point.
  void setCheckpoint(Vector2 groundPoint) {
    playerSpawn.setValues(groundPoint.x, groundPoint.y - 48);
  }

  /// Main menu / stage select entry point.
  void startRun(int stage, {bool newRun = false}) {
    if (newRun) {
      scoreCoins.value = 0;
      enemiesDefeated = 0;
      unawaited(savePrefs());
    }
    currentStage.value = max(1, min(4, stage));
    hp.value = hpMax;
    _hideOverlay('MainMenu');
    restart(showLoadCard: true);
  }

  void togglePause() {
    if (overlays.isActive('MainMenu') ||
        overlays.isActive('GameOver') ||
        overlays.isActive('Victory') ||
        overlays.isActive('LevelComplete')) {
      return;
    }
    if (overlays.isActive('PauseMenu')) {
      isPaused = false;
      _hideOverlay('PauseMenu');
      BroskieAudio.resumeBgm();
    } else {
      isPaused = true;
      BroskieAudio.pauseBgm();
      _showOverlay('PauseMenu');
    }
  }

  void requestPauseFromOs() {
    if (overlays.isActive('MainMenu')) return;
    if (!overlays.isActive('PauseMenu')) togglePause();
  }

  /// Called by the LevelComplete overlay's NEXT LEVEL button.
  void advanceStage() {
    _hideOverlay('LevelComplete');
    if (currentStage.value < 4) {
      currentStage.value++;
      if (currentStage.value > unlockedStage.value) {
        unlockedStage.value = currentStage.value;
      }
      unawaited(savePrefs());
      restart(showLoadCard: true);
    } else {
      unawaited(savePrefs());
      pauseEngine();
      _showOverlay('Victory');
    }
  }

  void _buildCurrentStage() {
    // Full stage (re)build always starts Broskie at the stage entrance.
    playerSpawn.setValues(100, 300);
    stageTime = 0;
    player = Player(position: playerSpawn.clone());
    add(player);
    _updateMarioCamera();
    // Spawn grace: three heartbeats of mercy before the world gets teeth.
    player.isInvulnerable = true;
    player.invulnerableTimer = 3.0;

    // Stage theme swap (the boot build sits silently paused behind the menu).
    if (!overlays.isActive('MainMenu') && !overlays.isActive('StageLoad')) {
      BroskieAudio.playStageTheme(currentStage.value);
      _showOverlay('StageBanner');
    } else if (overlays.isActive('StageLoad')) {
      BroskieAudio.playStageTheme(currentStage.value);
    }

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
    _levelWidth = 2800;
    add(StageBackdrop(
        imagePath: 'runtime/grey_zone_background.png', levelWidth: 2800));

    add(Floor(Vector2(-200, 480), Vector2(3000, 120)));
    add(InteractableBlock(
        position: Vector2(300, 340), type: BlockType.mystery));
    add(InteractableBlock(position: Vector2(332, 340), type: BlockType.brick));
    add(DataBitCoin(position: Vector2(500, 380)));
    add(DataBitCoin(position: Vector2(540, 380)));
    // Hidden stash: hovering above the mystery blocks — climb and grab.
    add(DataBitCoin(position: Vector2(316, 216)));
    add(DataBitCoin(position: Vector2(348, 216)));

    // Onboarding trail: one verb per sign, spaced like an arcade attract mode.
    add(InteractableLore(
      position: Vector2(180, 432),
      speaker: "STREET RULES",
      text:
          "THUMBS: left/right to run. Hold A to jump higher — tap A for a short hop.",
    ));
    add(InteractableLore(
      position: Vector2(620, 432),
      speaker: "VOLT DASH",
      text:
          "SPRAY is the Volt Dash. Use it to close gaps. It does not make you invincible.",
    ));
    add(InteractableLore(
      position: Vector2(1050, 432),
      speaker: "VINYL ARTILLERY",
      text:
          "B throws the vinyl. It comes back. Stomp anything grey. That's the whole game.",
    ));

    add(GrumpyBrick(position: Vector2(800, 448), patrolRange: 300));
    add(GrumpyBrick(position: Vector2(1200, 448), patrolRange: 300));
    add(CheckpointFlag(position: Vector2(1500, 416)));
    add(LevelExit(position: Vector2(2500, 352)));
  }

  void _buildStage2NeonSlums() {
    _levelWidth = 3500;
    add(StageBackdrop(
        imagePath: 'runtime/neon_slums_background.png', levelWidth: 3500));

    add(Floor(Vector2(-200, 480), Vector2(1500, 120)));
    add(DataSpike(position: Vector2(1301, 480), size: Vector2(699, 32)));

    add(MovingPlatform(
      position: Vector2(1450, 320),
      size: Vector2(120, 24),
      targetPos: Vector2(1850, 320),
      speed: 160,
    ));

    // Hidden stash: floating over the spike gap — time it with the ferry.
    add(DataBitCoin(position: Vector2(1600, 400)));
    add(DataBitCoin(position: Vector2(1760, 420)));

    add(Floor(Vector2(2000, 340), Vector2(1500, 120)));
    add(CheckpointFlag(position: Vector2(2100, 276)));
    add(PropagandaSign(position: Vector2(2200, 276)));
    add(LaserHazard(position: Vector2(2500, 180), size: Vector2(12, 160)));
    add(HaterCloud(position: Vector2(2700, 180)));
    add(LevelExit(position: Vector2(3300, 212)));
  }

  void _buildStage3StockExchange() {
    _levelWidth = 3200;
    add(StageBackdrop(
        imagePath: 'runtime/factory_background.png', levelWidth: 3200));

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
    add(CheckpointFlag(position: Vector2(2000, 116)));
    // Hidden stash: dangling past the tower's far lip.
    add(DataBitCoin(position: Vector2(2980, 100)));
    add(DataBitCoin(position: Vector2(3030, 100)));
    add(AuditorEnemy(position: Vector2(2200, 116)));
    add(LevelExit(position: Vector2(2900, 52)));
  }

  void _buildStage4ExecutiveArena() {
    _levelWidth = 3800;
    add(StageBackdrop(
        imagePath: 'runtime/monopoly_core_background.png', levelWidth: 3800));

    add(Floor(Vector2(-200, 480), Vector2(4000, 120)));

    add(InteractableLore(
      position: Vector2(180, 432),
      speaker: "FINAL STAGE",
      text:
          "EXECUTIVE ARENA: Bait the Foreman's charge into the arena walls, then stomp him. Burn the Data-Broker with boomerangs!",
    ));

    add(BossIntroTrigger(
      position: Vector2(420, 280),
      bossName: 'THE FOREMAN',
      bossTitle: 'MNPLY-042 · MANAGEMENT HARDWARE',
      bossArt: 'foreman_intro.png',
    ));
    add(TheForeman(position: Vector2(900, 400), minX: 500, maxX: 1900));
    add(BossIntroTrigger(
      position: Vector2(2150, 280),
      bossName: 'DATA-BROKER',
      bossTitle: 'MNPLY-0DAY · SIGNAL THIEF',
      bossArt: 'broker_intro.png',
    ));
    // Broker waits in the wings until the Foreman is actually gone.
    _brokerReleased = false;
    add(CheckpointFlag(position: Vector2(2100, 416)));
    // Mid-arena supply: cash for the shop between the two executives.
    add(DataBitCoin(position: Vector2(2230, 360)));
    add(DataBitCoin(position: Vector2(2280, 360)));
    add(LevelExit(
      position: Vector2(3600, 352),
      lockCondition: () =>
          children.whereType<TheForeman>().isNotEmpty ||
          children.whereType<DataBrokerBoss>().isNotEmpty ||
          !_brokerReleased,
      lockHint: "PORTAL JAMMED: Defeat BOTH executives to go live!",
    ));
  }

  /// One executive at a time. The Broker clocks in after the Foreman clocks out.
  void _maybeReleaseBroker() {
    if (currentStage.value != 4 || _brokerReleased) return;
    if (children.whereType<TheForeman>().isNotEmpty) return;
    _brokerReleased = true;
    add(DataBrokerBoss(position: Vector2(2600, 406), minX: 2300, maxX: 3200));
  }

  /// Falling off the world respawns at the last checkpoint.
  /// If a pit already taxed a heart this airborne, we do not charge a second.
  void onPlayerFell() {
    player.position.setFrom(playerSpawn);
    player.velocity.setZero();
    player.riding = null;
    player.isInvulnerable = true;
    player.invulnerableTimer = difficulty.value.iFrameSeconds;
    if (!fallTaxed) {
      fallTaxed = true;
      BroskieAudio.playHit();
      hp.value -= 1;
      triggerScreenShake(intensity: 0.6);
      if (hp.value <= 0) {
        triggerGameOver();
        return;
      }
    }
    if (!overlaysMuted && hp.value > 0) {
      _showOverlay('DeathCard');
    }
  }

  void triggerGameOver() {
    triggerScreenShake(intensity: 1.5);
    pauseEngine();
    _showOverlay('GameOver');
  }

  void triggerLevelComplete() {
    final rank = stageRankFor(currentStage.value, hp.value, stageTime,
        maxHearts: hpMax);
    lastRank = rank;
    if (rankValue(rank) > (bestRanks[currentStage.value] ?? 0)) {
      bestRanks[currentStage.value] = rankValue(rank);
      unawaited(savePrefs());
    }
    // An S gets the gold-record fanfare; anything less gets the standard sting.
    if (rank == 'S') {
      BroskieAudio.playFanfareS();
    } else {
      BroskieAudio.playStageComplete();
    }
    unawaited(savePrefs());
    pauseEngine();
    _showOverlay('LevelComplete');
  }

  void showDialogue(String speaker, String text) {
    activeSpeaker = speaker;
    activeDialogue = text;
    _showOverlay('Dialogue');
  }

  void hideDialogue() {
    _hideOverlay('Dialogue');
  }

  void restart({bool showLoadCard = false}) {
    _hideOverlay('GameOver');
    _hideOverlay('LevelComplete');
    _hideOverlay('Dialogue');
    _hideOverlay('PauseMenu');
    _hideOverlay('Shop');
    _hideOverlay('Victory');
    _hideOverlay('BossCard');
    _hideOverlay('StageBanner');
    _hideOverlay('DeathCard');
    hideBossBar();
    screenFlash.value = 0;

    hp.value = hpMax;
    if (showLoadCard) _showOverlay('StageLoad');

    // Keep the persistent shell: hitbox + whatever sky was loaded in onLoad.
    // Everything else (player, stages, bosses, backdrops) is rebuilt fresh.
    for (final c in children
        .where((c) => c is! ParallaxComponent && c is! ProceduralSkylineParallax)
        .toList()) {
      c.removeFromParent();
    }

    _buildCurrentStage();
    _syncEnginePause();
    if (overlaysMuted) resumeEngine();
  }

  @override
  Color backgroundColor() => const Color(0xFF12100C);
}

class Floor extends PositionComponent
    with HasGameReference<BroskieGame>, CollisionCallbacks {
  Floor(Vector2 position, Vector2 size)
      : super(position: position, size: size) {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final darkConcrete = Paint()..color = const Color(0xFF222533);
    // The neon edge breathes on the stage beat.
    final topNeonLine = Paint()
      ..color = const Color(0xFF00E5FF)
          .withValues(alpha: 0.45 + 0.55 * game.beatPulse);
    final gridLine = Paint()
      ..color = const Color(0xFF33384A)
      ..strokeWidth = 1;

    canvas.drawRect(rect, darkConcrete);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 6),
        Paint()..color = const Color(0xFFF2E6D4));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 2), topNeonLine);

    for (double x = 0; x < size.x; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridLine);
    }
    for (double y = 0; y < size.y; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridLine);
    }
  }
}

class ProceduralSkylineParallax extends Component
    with HasGameReference<BroskieGame> {
  double scrollX = 0;

  @override
  void update(double dt) {
    scrollX += 20 * dt;
  }

  @override
  void render(Canvas canvas) {
    final size = game.size;
    final skyPaint = Paint()..color = const Color(0xFF140D2B);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), skyPaint);

    final bldgPaintFar = Paint()..color = const Color(0xFF211442);
    for (double x = -100; x < size.x + 200; x += 80) {
      double drawX = (x - scrollX * 0.3) % (size.x + 200) - 100;
      canvas.drawRect(
          Rect.fromLTWH(drawX, size.y - 250, 70, 250), bldgPaintFar);
    }

    final bldgPaintNear = Paint()..color = const Color(0xFF2E195E);
    for (double x = -100; x < size.x + 200; x += 120) {
      double drawX = (x - scrollX * 0.7) % (size.x + 200) - 100;
      canvas.drawRect(
          Rect.fromLTWH(drawX, size.y - 180, 100, 180), bldgPaintNear);
    }
  }
}
