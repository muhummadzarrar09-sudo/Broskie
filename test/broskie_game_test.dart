import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/levels/level_exit.dart';
import 'package:broskie_game/game/player.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithGame<BroskieGame>(
    'boots stage 1 with a player, floors and an exit',
    BroskieGame.new,
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
    BroskieGame.new,
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
    BroskieGame.new,
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
    'advanceStage moves to the next stage and rebuilds it',
    BroskieGame.new,
    (game) async {
      await game.ready();

      game.advanceStage();
      await game.ready();
      game.update(0.016);

      expect(game.currentStage.value, 2);
      expect(game.children.whereType<Player>(), hasLength(1));
      expect(game.children.whereType<LevelExit>(), hasLength(1));
    },
  );
}
