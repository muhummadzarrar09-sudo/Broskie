import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/broskie_game.dart';
import 'game/ui/credits_overlay.dart';
import 'game/ui/ending_overlay.dart';
import 'game/ui/game_over.dart';
import 'game/ui/hud_overlay.dart';
import 'game/ui/level_complete.dart';
import 'game/ui/loading_screen.dart';
import 'game/ui/main_menu.dart';
import 'game/ui/pause_overlay.dart';
import 'game/ui/settings_overlay.dart';
import 'game/ui/stage_intro.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const BroskieApp());
}

class BroskieApp extends StatefulWidget {
  const BroskieApp({super.key});

  @override
  State<BroskieApp> createState() => _BroskieAppState();
}

class _BroskieAppState extends State<BroskieApp> {
  late final BroskieGame _game = BroskieGame();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Broskie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF47F8FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF050711),
        body: GameWidget<BroskieGame>(
          game: _game,
          loadingBuilder: (context) => const BroskieLoadingScreen(),
          errorBuilder: (context, error) => BroskieLoadError(error: error),
          overlayBuilderMap: {
            BroskieGame.hudOverlay: (context, game) => BroskieHud(game: game),
            BroskieGame.menuOverlay: (context, game) =>
                MainMenuOverlay(game: game),
            BroskieGame.stageIntroOverlay: (context, game) =>
                StageIntroOverlay(game: game),
            BroskieGame.settingsOverlay: (context, game) =>
                SettingsOverlay(game: game),
            BroskieGame.creditsOverlay: (context, game) =>
                CreditsOverlay(onClose: game.closeCredits),
            BroskieGame.pauseOverlay: (context, game) => PauseOverlay(
              onResume: game.togglePause,
              onRestart: game.restartStage,
              onSettings: game.openSettings,
              onMenu: game.showMenu,
            ),
            BroskieGame.gameOverOverlay: (context, game) => GameOverOverlay(
              onRestart: game.restartStage,
              onMenu: game.showMenu,
            ),
            BroskieGame.completeOverlay: (context, game) {
              final result = game.lastResult;
              if (result == null) {
                return const SizedBox.shrink();
              }
              return LevelCompleteOverlay(
                result: result,
                finalStage: game.currentStageIndex == 3,
                onNext: game.nextStage,
                onReplay: game.restartStage,
                onMenu: game.showMenu,
              );
            },
            BroskieGame.endingOverlay: (context, game) =>
                EndingOverlay(game: game),
          },
          initialActiveOverlays: const [BroskieGame.menuOverlay],
        ),
      ),
    );
  }
}
