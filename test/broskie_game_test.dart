import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/enemies/foreman_boss.dart';
import 'package:broskie_game/game/player.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWithGame<BroskieGame>(
    'loads a playable vertical slice into the camera world',
    BroskieGame.new,
    (game) async {
      await game.ready();

      expect(game.player, isA<Player>());
      expect(game.player.parent, same(game.world));
      expect(game.solids.length, greaterThanOrEqualTo(10));
      expect(game.world.children.whereType<TheForeman>(), hasLength(1));
      expect(game.exit.unlocked, isFalse);
    },
  );

  testWithGame<BroskieGame>(
    'rejects invalid cash awards and unlocks the exit after the boss',
    BroskieGame.new,
    (game) async {
      await game.ready();

      game.collectCash(-500);
      expect(game.cash, 0);

      game.bossDefeated();
      await game.ready();
      expect(game.cash, 1000);
      expect(game.exit.unlocked, isTrue);
      expect(game.solids.contains(game.bossGate), isFalse);
    },
  );
}
