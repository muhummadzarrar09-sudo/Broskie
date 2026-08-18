import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/models/game_hud_state.dart';
import 'package:broskie_game/game/services/campaign_repository.dart';
import 'package:broskie_game/game/ui/hud_overlay.dart';
import 'package:broskie_game/game/ui/pause_overlay.dart';
import 'package:broskie_game/game/ui/settings_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HUD and touch controls fit a short landscape phone', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(640, 360)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final game = BroskieGame(campaignRepository: MemoryCampaignRepository());
    game.hud.value = const GameHudState(
      health: 3,
      cash: 9999,
      progress: 0.5,
      flow: 88,
      powered: true,
      bossHealth: 8,
      bossMaxHealth: 10,
      stageNumber: 4,
      stageTitle: 'MONOPOLY CORE',
      elapsedSeconds: 125,
      controlsInverted: true,
      broadcast: 'LAYOUT STRESS TEST',
      phase: GamePhase.playing,
    );

    await tester.pumpWidget(MaterialApp(home: BroskieHud(game: game)));
    expect(tester.takeException(), isNull);
  });

  testWidgets('pause and settings overlays scroll on compact screens', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(480, 300)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final game = BroskieGame(campaignRepository: MemoryCampaignRepository());

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            PauseOverlay(
              onResume: () {},
              onRestart: () {},
              onSettings: () {},
              onMenu: () {},
            ),
            SettingsOverlay(game: game),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
