import 'campaign_progress.dart';

enum GamePhase {
  menu,
  stageIntro,
  playing,
  paused,
  gameOver,
  stageComplete,
  ending,
}

class GameHudState {
  const GameHudState({
    required this.health,
    required this.cash,
    required this.progress,
    required this.flow,
    required this.powered,
    required this.bossHealth,
    required this.bossMaxHealth,
    required this.stageNumber,
    required this.stageTitle,
    required this.elapsedSeconds,
    required this.controlsInverted,
    required this.broadcast,
    required this.phase,
  });

  const GameHudState.initial()
    : health = 3,
      cash = 0,
      progress = 0,
      flow = 0,
      powered = false,
      bossHealth = 0,
      bossMaxHealth = 1,
      stageNumber = 1,
      stageTitle = 'THE GREY ZONE',
      elapsedSeconds = 0,
      controlsInverted = false,
      broadcast = null,
      phase = GamePhase.menu;

  final int health;
  final int cash;
  final double progress;
  final double flow;
  final bool powered;
  final int bossHealth;
  final int bossMaxHealth;
  final int stageNumber;
  final String stageTitle;
  final int elapsedSeconds;
  final bool controlsInverted;
  final String? broadcast;
  final GamePhase phase;

  bool get bossActive => bossHealth > 0;

  String get flowLabel {
    if (flow >= 85) {
      return 'UNGOVERNABLE';
    }
    if (flow >= 60) {
      return 'LOCKED IN';
    }
    if (flow >= 30) {
      return 'COOKING';
    }
    return 'CHILL';
  }
}

class StageResult {
  const StageResult({
    required this.cash,
    required this.enemiesDefeated,
    required this.elapsedSeconds,
    required this.rank,
  });

  final int cash;
  final int enemiesDefeated;
  final int elapsedSeconds;
  final CampaignRank rank;
}
