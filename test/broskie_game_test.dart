import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/enemies/data_broker_boss.dart';
import 'package:broskie_game/game/enemies/foreman_boss.dart';
import 'package:broskie_game/game/levels/level_exit.dart';
import 'package:broskie_game/game/player.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tests run the game headless: there is no GameWidget, so Flame has no
/// overlay builders registered. Muting keeps overlay calls as no-ops while
/// every notifier (bossBar, hp, screenFlash) stays fully observable.
BroskieGame createMutedGame() => BroskieGame()..overlaysMuted = true;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stage rank math is honest', () {
    expect(BroskieGame.stageRankFor(1, 3, 20), 'S'); // flawless and under par
    expect(BroskieGame.stageRankFor(1, 2, 40), 'A'); // 2 hearts, within 1.5x par
    expect(BroskieGame.stageRankFor(1, 1, 40), 'B'); // survived within 2x par
    expect(BroskieGame.stageRankFor(1, 1, 80), 'C'); // barely made it
  });

  testWithGame<BroskieGame>(
    'boots stage 1 with a player, floors and an exit',
    createMutedGame,
    (game) async {
      await game.ready();

      expect(game.children.whereType<Player>(), hasLength(1));
      expect(game.children.whereType<Floor>(), isNotEmpty);
      expect(game.children.whereType<LevelExit>(), hasLength(1));
      expect(game.currentStage.value, 1);
      expect(game.hp.value, BroskieGame.maxHp);
    },
  );

  testWithGame<BroskieGame>(
    'restart rebuilds the stage and restores hearts',
    createMutedGame,
    (game) async {
      await game.ready();

      game.hp.value = 1;
      game.restart();
      await game.ready();
      game.update(0.016);

      expect(game.hp.value, BroskieGame.maxHp);
      expect(game.children.whereType<Player>(), hasLength(1));
      expect(game.children.whereType<Floor>(), isNotEmpty);
    },
  );

  testWithGame<BroskieGame>(
    'falling off the world costs a heart and respawns the player',
    createMutedGame,
    (game) async {
      await game.ready();

      game.player.position.setValues(500, 500);
      game.onPlayerFell();

      expect(game.hp.value, BroskieGame.maxHp - 1);
      expect(game.player.position.x, game.playerSpawn.x);
      expect(game.player.position.y, game.playerSpawn.y);
    },
  );

  testWithGame<BroskieGame>(
    'advanceStage moves to the next stage, unlocks it and rebuilds',
    createMutedGame,
    (game) async {
      await game.ready();

      game.advanceStage();
      await game.ready();
      game.update(0.016);

      expect(game.currentStage.value, 2);
      expect(game.unlockedStage.value, 2);
      expect(game.children.whereType<Player>(), hasLength(1));
      expect(game.children.whereType<LevelExit>(), hasLength(1));
    },
  );

  testWithGame<BroskieGame>(
    'checkpoints move the respawn point',
    createMutedGame,
    (game) async {
      await game.ready();

      game.setCheckpoint(Vector2(2100, 340));
      game.player.position.setValues(900, 900);
      game.onPlayerFell();

      expect(game.hp.value, BroskieGame.maxHp - 1);
      expect(game.player.position.x, 2100);
      expect(game.player.position.y, 340 - 48);
    },
  );

  testWithGame<BroskieGame>(
    'the stage 4 exit stays locked until both executives are down',
    createMutedGame,
    (game) async {
      await game.ready();

      game.currentStage.value = 4;
      game.restart();
      await game.ready();
      game.update(0.3); // let the exit poll its lock condition

      final exit = game.children.whereType<LevelExit>().single;
      expect(exit.locked, isTrue);

      game.children.whereType<TheForeman>().forEach((c) => c.removeFromParent());
      game.children.whereType<DataBrokerBoss>().forEach((c) => c.removeFromParent());
      game.update(0.016); // process pending removals
      game.update(0.3); // let the exit poll again

      expect(exit.locked, isFalse);
    },
  );

  test('rank boundaries: par is inclusive, S demands full health', () {
    expect(BroskieGame.stageRankFor(2, 3, 50), 'S'); // exactly at par certifies gold
    expect(BroskieGame.stageRankFor(2, 3, 50.01), 'A'); // full health but over par
    expect(BroskieGame.stageRankFor(2, 2, 49), 'A'); // flawless time, one hit taken — no S
    expect(BroskieGame.stageRankFor(1, 3, 36), 'A'); // full health, 1s over par
    expect(BroskieGame.stageRankFor(1, 1, 100), 'C'); // slow AND bruised
    expect(BroskieGame.stageRankFor(1, 3, 69), 'B'); // full health but way over par
  });

  test('beatPulse stays inside [0,1] on every stage', () {
    final game = BroskieGame();
    for (var stage = 1; stage <= 4; stage++) {
      game.currentStage.value = stage;
      for (final t in [0.0, 0.17, 1.3, 42.42, 999.9]) {
        game.stageTime = t;
        expect(game.beatPulse, inInclusiveRange(0, 1), reason: 'stage $stage at t=$t');
      }
    }
  });

  test('prefs: haptics toggle persists, unlock range clamps', () async {
    SharedPreferences.setMockInitialValues({'settings_haptics': false, 'unlocked_stage': 99});
    final game = BroskieGame();
    await game.loadPrefs();
    expect(game.hapticsEnabled.value, false);
    expect(game.unlockedStage.value, 4); // clamped to campaign max
  });

  testWithGame<BroskieGame>(
    'hit-stop freezes stage time, then releases it',
    createMutedGame,
    (game) async {
      await game.ready();

      game.hitStop(0.1);
      game.update(0.05);
      expect(game.stageTime, 0); // the world held its breath

      game.update(0.2); // burn through the freeze
      expect(game.stageTime, greaterThan(0));
    },
  );

  testWithGame<BroskieGame>(
    'boss bar and screen flash have a clean lifecycle',
    createMutedGame,
    (game) async {
      await game.ready();

      game.showBossBar('THE FOREMAN');
      expect(game.bossBarName, 'THE FOREMAN');
      expect(game.bossBar.value, 1.0);

      game.updateBossBar(0.5);
      expect(game.bossBar.value, 0.5);

      game.hideBossBar();
      expect(game.bossBar.value, -1);

      game.triggerScreenFlash(0.8);
      expect(game.screenFlash.value, 0.8);
      for (var i = 0; i < 120; i++) {
        game.update(1 / 60);
      }
      expect(game.screenFlash.value, 0); // fully faded out
    },
  );
}
