import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game/broskie_game.dart';
import 'game/ui/dialogue_box.dart';
import 'game/ui/game_over.dart';
import 'game/ui/level_complete.dart';
import 'game/ui/news_ticker.dart';

void main() {
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
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flash_on, color: Colors.amber, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            "BROSKIE | ${game.player.currentPower.name.toUpperCase()}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        border: Border.all(color: Colors.amber, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "DEFEATED: ${game.enemiesDefeated}",
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
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

          'GameOver': (context, game) => GameOverOverlay(
            onRestart: () => game.restart(),
          ),

          'LevelComplete': (context, game) => LevelCompleteOverlay(
            coins: game.scoreCoins,
            enemiesStomped: game.enemiesDefeated,
            onNextLevel: () => game.restart(),
          ),

          'Dialogue': (context, game) => DialogueBox(
            speakerName: game.activeSpeaker,
            text: game.activeDialogue,
            onNext: () => game.hideDialogue(),
          ),
        },
        initialActiveOverlays: const ['HUD'],
      ),
    );
  }
}
