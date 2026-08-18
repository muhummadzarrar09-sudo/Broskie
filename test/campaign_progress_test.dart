import 'package:broskie_game/game/models/campaign_progress.dart';
import 'package:broskie_game/game/services/campaign_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('campaign ranks and settings survive repository saves', () async {
    final repository = MemoryCampaignRepository();
    final progress = const CampaignProgress().copyWith(
      hasStarted: true,
      highestUnlockedStage: 2,
      bestRanks: [CampaignRank.a.index, CampaignRank.s.index, 0, 0],
      hapticsEnabled: false,
      audioEnabled: false,
      controlScale: 1.5,
      reducedEffects: true,
    );

    await repository.save(progress);
    final restored = await repository.load();

    expect(restored.hasStarted, isTrue);
    expect(restored.highestUnlockedStage, 2);
    expect(restored.rankFor(0), CampaignRank.a);
    expect(restored.rankFor(1), CampaignRank.s);
    expect(restored.hapticsEnabled, isFalse);
    expect(restored.audioEnabled, isFalse);
    expect(restored.controlScale, 1.5);
    expect(restored.reducedEffects, isTrue);
  });

  test('out-of-range rank lookups are safe', () {
    const progress = CampaignProgress();

    expect(progress.rankFor(-1), CampaignRank.unranked);
    expect(progress.rankFor(99), CampaignRank.unranked);
  });
}
