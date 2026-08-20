import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game/audio_manager.dart';
import 'game/broskie_game.dart';
import 'game/ui/boss_bar_overlay.dart';
import 'game/ui/boss_card_overlay.dart';
import 'game/ui/broskie_style.dart';
import 'game/ui/dialogue_box.dart';
import 'game/ui/game_over.dart';
import 'game/ui/level_complete.dart';
import 'game/ui/level_select.dart';
import 'game/ui/main_menu_screen.dart';
import 'game/ui/news_ticker.dart';
import 'game/ui/pause_menu.dart';
import 'game/ui/settings_overlay.dart';
import 'game/ui/shop_overlay.dart';
import 'game/ui/splash_screen.dart';
import 'game/ui/stage_banner_overlay.dart';
import 'game/ui/stage_load_overlay.dart';
import 'game/ui/touch_controls.dart';
import 'game/ui/victory_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await BroskieAudio.init();
  runApp(
    const ProviderScope(
      child: BroskieApp(),
    ),
  );
}

class BroskieApp extends ConsumerWidget {
  const BroskieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Broskie Game',
      theme: ThemeData.dark(),
      home: const SplashScreen(next: BroskieGameScreen()),
    );
  }
}

class BroskieGameScreen extends ConsumerStatefulWidget {
  const BroskieGameScreen({super.key});

  @override
  ConsumerState<BroskieGameScreen> createState() => _BroskieGameScreenState();
}

class _BroskieGameScreenState extends ConsumerState<BroskieGameScreen>
    with WidgetsBindingObserver {
  late BroskieGame game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    game = BroskieGame(ref: ref);
    // Load saved crew settings/unlocks, then start the chiptune.
    game.loadPrefs().then((_) => BroskieAudio.startMusic());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      game.requestPauseFromOs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (game.overlays.isActive('MainMenu')) {
          // Title screen: a second back can leave the activity.
          return;
        }
        game.requestPauseFromOs();
      },
      child: Scaffold(
        body: GameWidget<BroskieGame>(
        game: game,
        overlayBuilderMap: {
          'HUD': (context, game) => Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xE612100C),
                                border: Border.all(
                                    color: const Color(0xFFF2E6D4), width: 2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ValueListenableBuilder<int>(
                                    valueListenable: game.currentStage,
                                    builder: (context, stage, _) => Text(
                                      "STAGE $stage  BROSKIE",
                                      style: const TextStyle(
                                          color: Color(0xFFF2E6D4),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace'),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ValueListenableBuilder<int>(
                                    valueListenable: game.hp,
                                    builder: (context, hearts, _) =>
                                        ValueListenableBuilder(
                                      valueListenable: game.difficulty,
                                      builder: (context, _, __) => Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                          game.hpMax,
                                          (i) => Padding(
                                            padding:
                                                const EdgeInsets.only(right: 3),
                                            child: CustomPaint(
                                              size: const Size(21, 16),
                                              painter: PixelHeartPainter(
                                                  filled: i < hearts),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xE612100C),
                                    border: Border.all(
                                        color: const Color(0xFFFFB800),
                                        width: 2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: ValueListenableBuilder<int>(
                                    valueListenable: game.scoreCoins,
                                    builder: (context, coins, _) => Row(
                                      children: [
                                        const CustomPaint(
                                            size: Size(16, 16),
                                            painter: PixelVinylPainter()),
                                        const SizedBox(width: 6),
                                        Text(
                                          "VINYL $coins",
                                          style: const TextStyle(
                                              color: Color(0xFFFFB800),
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'monospace'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.map,
                                      color: Color(0xFFFFB800), size: 28),
                                  onPressed: () {
                                    BroskieAudio.playUiClick();
                                    game.openLevelSelect();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings,
                                      color: Color(0xFFF2E6D4), size: 28),
                                  onPressed: () {
                                    BroskieAudio.playUiClick();
                                    game.openSettings();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.pause,
                                      color: Color(0xFFFFB800), size: 32),
                                  onPressed: () {
                                    BroskieAudio.playUiClick();
                                    game.togglePause();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: game.touchControlsEnabled,
                    builder: (context, enabled, _) => enabled
                        ? TouchControlsOverlay(game: game)
                        : const SizedBox.shrink(),
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: NewsTickerOverlay(
                        headlines: [
                          "MONOPOLY CORP BANS UNAUTHORIZED CHILL",
                          "BROSKIE SPOTTED IN THE GREY ZONE",
                          "THE FOREMAN WANTS A WORD",
                          "DATA-BROKER SELLING YOUR JUMPS",
                        ],
                      ),
                    ),
                  ),
                ],
              ),

          'MainMenu': (context, game) => MainMenuOverlay(game: game),

          'BossCard': (context, game) => BossCardOverlay(game: game),
          'BossBar': (context, game) => BossBarOverlay(game: game),
          // ScreenFlash renders above everything and must NOT be scan-wrapped:
          // it IS the white frame.
          'ScreenFlash': (context, game) => ScreenFlashOverlay(game: game),

          'StageBanner': (context, game) => StageBannerOverlay(game: game),
          'StageLoad': (context, game) => StageLoadOverlay(game: game),
          'DeathCard': (context, game) => DeathCardOverlay(game: game),
          'LevelSelect': (context, game) => LevelSelectOverlay(game: game),
          'Settings': (context, game) => SettingsOverlay(game: game),
          'PauseMenu': (context, game) => PauseMenuOverlay(game: game),
          'Shop': (context, game) => ShopOverlay(game: game),
          'Victory': (context, game) => VictoryOverlay(game: game),
          'GameOver': (context, game) => GameOverOverlay(
                onRestart: () {
                  BroskieAudio.playUiClick();
                  game.restart(showLoadCard: true);
                },
              ),
          'LevelComplete': (context, game) => LevelCompleteOverlay(
                coins: game.scoreCoins.value,
                enemiesStomped: game.enemiesDefeated,
                rank: game.lastRank,
                bestRank: game.bestRankLabelFor(game.currentStage.value),
                isLastStage: game.currentStage.value >= 4,
                onNextLevel: () {
                  BroskieAudio.playUiClick();
                  game.advanceStage();
                },
              ),
          'Dialogue': (context, game) => DialogueBox(
                speakerName: game.activeSpeaker,
                text: game.activeDialogue,
                onNext: () {
                  BroskieAudio.playUiClick();
                  game.hideDialogue();
                },
              ),
        },
          initialActiveOverlays: const ['HUD', 'MainMenu', 'ScreenFlash'],
        ),
      ),
    );
  }
}
