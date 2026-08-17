import 'package:shared_preferences/shared_preferences.dart';

import '../models/campaign_progress.dart';

abstract class CampaignRepository {
  Future<CampaignProgress> load();

  Future<void> save(CampaignProgress progress);
}

class SharedPreferencesCampaignRepository implements CampaignRepository {
  static const _startedKey = 'campaign.started';
  static const _unlockedKey = 'campaign.highestUnlocked';
  static const _ranksKey = 'campaign.bestRanks';
  static const _hapticsKey = 'settings.haptics';
  static const _controlsKey = 'settings.touchControls';
  static const _effectsKey = 'settings.reducedEffects';

  @override
  Future<CampaignProgress> load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedRanks = preferences.getStringList(_ranksKey) ?? const [];
    final ranks = List<int>.generate(
      4,
      (index) => index < storedRanks.length
          ? int.tryParse(storedRanks[index]) ?? 0
          : 0,
    );
    return CampaignProgress(
      hasStarted: preferences.getBool(_startedKey) ?? false,
      highestUnlockedStage: (preferences.getInt(_unlockedKey) ?? 0)
          .clamp(0, 3)
          .toInt(),
      bestRanks: ranks,
      hapticsEnabled: preferences.getBool(_hapticsKey) ?? true,
      showTouchControls: preferences.getBool(_controlsKey) ?? true,
      reducedEffects: preferences.getBool(_effectsKey) ?? false,
    );
  }

  @override
  Future<void> save(CampaignProgress progress) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setBool(_startedKey, progress.hasStarted),
      preferences.setInt(_unlockedKey, progress.highestUnlockedStage),
      preferences.setStringList(
        _ranksKey,
        progress.bestRanks.map((rank) => '$rank').toList(growable: false),
      ),
      preferences.setBool(_hapticsKey, progress.hapticsEnabled),
      preferences.setBool(_controlsKey, progress.showTouchControls),
      preferences.setBool(_effectsKey, progress.reducedEffects),
    ]);
  }
}

class MemoryCampaignRepository implements CampaignRepository {
  MemoryCampaignRepository([this.progress = const CampaignProgress()]);

  CampaignProgress progress;

  @override
  Future<CampaignProgress> load() async => progress;

  @override
  Future<void> save(CampaignProgress progress) async {
    this.progress = progress;
  }
}
