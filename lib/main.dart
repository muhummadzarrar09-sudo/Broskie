import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/broskie_game.dart';
import 'game/models/game_hud_state.dart';
import 'game/ui/game_over.dart';
import 'game/ui/hud_overlay.dart';
import 'game/ui/level_complete.dart';
import 'game/ui/pause_overlay.dart';

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
          overlayBuilderMap: {
            BroskieGame.hudOverlay: (context, game) => BroskieHud(game: game),
            BroskieGame.pauseOverlay: (context, game) => PauseOverlay(
              onResume: game.togglePause,
              onRestart: game.restartUnawaited,
            ),
            BroskieGame.gameOverOverlay: (context, game) => GameOverOverlay(
              onRestart: game.restartUnawaited,
            ),
            BroskieGame.completeOverlay: (context, game) =>
                ValueListenableBuilder<GameHudState>(
                  valueListenable: game.hud,
                  builder: (context, state, _) => LevelCompleteOverlay(
                    cash: state.cash,
                    enemiesStomped: game.enemiesDefeated,
                    onReplay: game.restartUnawaited,
                  ),
                ),
          },
          initialActiveOverlays: const [BroskieGame.hudOverlay],
        ),
      ),
    );
  }
}
