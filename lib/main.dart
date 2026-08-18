import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game/audio_manager.dart';
import 'game/broskie_game.dart';
import 'game/ui/dialogue_box.dart';
import 'game/ui/game_over.dart';
import 'game/ui/level_complete.dart';
import 'game/ui/main_menu_screen.dart';
import 'game/ui/news_ticker.dart';
import 'game/ui/touch_controls.dart';
import 'game/ui/pause_menu.dart';
import 'game/ui/shop_overlay.dart';
import 'game/ui/level_select.dart';
import 'game/ui/settings_overlay.dart';
import 'game/ui/victory_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const BroskieGameScreen(),
    );
  }
}

class BroskieGameScreen extends ConsumerStatefulWidget {
  const BroskieGameScreen({super.key});

  @override
  ConsumerState<BroskieGameScreen> createState() => _BroskieGameScreenState();
}

class _BroskieGameScreenState extends ConsumerState<BroskieGameScreen> {
  late BroskieGame game;

  @override
  void initState() {
    super.initState();
    game = BroskieGame(ref: ref);
    // Load saved crew settings/unlocks, then start the chiptune.
    game.loadPrefs().then((_) => BroskieAudio.startMusic());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<BroskieGame>(
        game: game,
        overlayBuilderMap: {
          'HUD': (context, game) => Stack(
            children: [
              // Top Bar Status HUD
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flash_on, color: Colors.amber, size: 20),
                              const SizedBox(width: 6),
                              ValueListenableBuilder<int>(
                                valueListenable: game.currentStage,
                                builder: (context, stage, _) => Text(
                                  "STAGE $stage | BROSKIE",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ValueListenableBuilder<int>(
                            valueListenable: game.hp,
                            builder: (context, hearts, _) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                BroskieGame.maxHp,
                                (i) => Icon(
                                  i < hearts ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.redAccent,
                                  size: 18,
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            border: Border.all(color: Colors.amber, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ValueListenableBuilder<int>(
                            valueListenable: game.scoreCoins,
                            builder: (context, coins, _) => Text(
                              "CASH: \$$coins",
                              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Stage Select Button
                        IconButton(
                          icon: const Icon(Icons.map, color: Colors.amber, size: 32),
                          onPressed: () => game.overlays.add('LevelSelect'),
                        ),

                        // Settings Button
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.grey, size: 32),
                          onPressed: () => game.overlays.add('Settings'),
                        ),

                        // Pause Button
                        IconButton(
                          icon: const Icon(Icons.pause_circle_filled, color: Color(0xFF00E5FF), size: 36),
                          onPressed: () => game.togglePause(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Floating Mobile Touch Controls Overlay (settings-gated)
              ValueListenableBuilder<bool>(
                valueListenable: game.touchControlsEnabled,
                builder: (context, enabled, _) =>
                    enabled ? TouchControlsOverlay(game: game) : const SizedBox.shrink(),
              ),

              // Bottom News Ticker
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: NewsTickerOverlay(
                  headlines: [
                    "MONOPOLY CORP: 'All unauthorized chill is hereby prohibited!'",
                    "BROSKIE SPOTTED IN THE GREY ZONE WITH VOLT-COLA!",
                    "THE FOREMAN INITIATES AGGRESSIVE RESTRUCTURING IN SECTOR 1-8!",
                    "DATA-BROKER DENIES SINKING BANDWIDTH IN NEON SLUMS!",
                  ],
                ),
              ),
            ],
          ),

          'MainMenu': (context, game) => MainMenuOverlay(game: game),

          'LevelSelect': (context, game) => LevelSelectOverlay(game: game),

          'Settings': (context, game) => SettingsOverlay(game: game),

          'PauseMenu': (context, game) => PauseMenuOverlay(game: game),

          'Shop': (context, game) => ShopOverlay(game: game),

          'Victory': (context, game) => VictoryOverlay(game: game),

          'GameOver': (context, game) => GameOverOverlay(
            onRestart: () => game.restart(),
          ),

          'LevelComplete': (context, game) => LevelCompleteOverlay(
            coins: game.scoreCoins.value,
            enemiesStomped: game.enemiesDefeated,
            rank: game.lastRank,
            bestRank: game.bestRankLabelFor(game.currentStage.value),
            onNextLevel: () => game.advanceStage(),
          ),

          'Dialogue': (context, game) => DialogueBox(
            speakerName: game.activeSpeaker,
            text: game.activeDialogue,
            onNext: () => game.hideDialogue(),
          ),
        },
        initialActiveOverlays: const ['HUD', 'MainMenu'],
      ),
    );
  }
}
