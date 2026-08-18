import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/enemies/data_broker_boss.dart';
import 'package:broskie_game/game/enemies/foreman_boss.dart';
import 'package:broskie_game/game/models/game_hud_state.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/services/campaign_repository.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithGame<BroskieGame>(
    'loads the first campaign stage into the camera world',
    () => BroskieGame(campaignRepository: MemoryCampaignRepository()),
    (game) async {
      await game.ready();

      expect(game.phase, GamePhase.menu);
      expect(game.player, isA<Player>());
      expect(game.player.parent, same(game.world));
      expect(game.solids.length, greaterThanOrEqualTo(10));
      expect(game.exit.unlocked, isTrue);
    },
  );

  testWithGame<BroskieGame>(
    'loads both campaign bosses on their intended stages',
    () => BroskieGame(campaignRepository: MemoryCampaignRepository()),
    (game) async {
      await game.prepareStage(1);
      expect(game.world.children.whereType<TheForeman>(), hasLength(1));
      expect(game.exit.unlocked, isFalse);

      await game.prepareStage(3);
      expect(game.world.children.whereType<DataBrokerBoss>(), hasLength(1));
      expect(game.exit.unlocked, isFalse);
    },
  );

  testWithGame<BroskieGame>(
    'rejects invalid cash and persists stage progression',
    () => BroskieGame(campaignRepository: MemoryCampaignRepository()),
    (game) async {
      await game.prepareStage(1);
      game.beginStage();
      game.collectCash(-500);
      expect(game.cash, 0);

      game.bossDefeated();
      expect(game.exit.unlocked, isTrue);
      game.completeLevel();

      expect(game.phase, GamePhase.stageComplete);
      expect(game.progress.highestUnlockedStage, 2);
      expect(game.lastResult, isNotNull);
    },
  );
}
