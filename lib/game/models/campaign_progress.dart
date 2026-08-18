enum CampaignRank { unranked, c, b, a, s }

extension CampaignRankLabel on CampaignRank {
  String get label {
    switch (this) {
      case CampaignRank.unranked:
        return '—';
      case CampaignRank.c:
        return 'C';
      case CampaignRank.b:
        return 'B';
      case CampaignRank.a:
        return 'A';
      case CampaignRank.s:
        return 'S';
    }
  }
}

class CampaignProgress {
  const CampaignProgress({
    this.hasStarted = false,
    this.highestUnlockedStage = 0,
    this.bestRanks = const [0, 0, 0, 0],
    this.hapticsEnabled = true,
    this.audioEnabled = true,
    this.showTouchControls = true,
    this.controlScale = 1.25,
    this.reducedEffects = false,
  });

  final bool hasStarted;
  final int highestUnlockedStage;
  final List<int> bestRanks;
  final bool hapticsEnabled;
  final bool audioEnabled;
  final bool showTouchControls;
  final double controlScale;
  final bool reducedEffects;

  CampaignRank rankFor(int stage) {
    if (stage < 0 || stage >= bestRanks.length) {
      return CampaignRank.unranked;
    }
    return CampaignRank.values[bestRanks[stage].clamp(0, 4).toInt()];
  }

  CampaignProgress copyWith({
    bool? hasStarted,
    int? highestUnlockedStage,
    List<int>? bestRanks,
    bool? hapticsEnabled,
    bool? audioEnabled,
    bool? showTouchControls,
    double? controlScale,
    bool? reducedEffects,
  }) {
    return CampaignProgress(
      hasStarted: hasStarted ?? this.hasStarted,
      highestUnlockedStage: highestUnlockedStage ?? this.highestUnlockedStage,
      bestRanks: List.unmodifiable(bestRanks ?? this.bestRanks),
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      showTouchControls: showTouchControls ?? this.showTouchControls,
      controlScale: controlScale ?? this.controlScale,
      reducedEffects: reducedEffects ?? this.reducedEffects,
    );
  }
}
