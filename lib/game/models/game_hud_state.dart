enum GamePhase { playing, paused, gameOver, complete }

class GameHudState {
  const GameHudState({
    required this.health,
    required this.cash,
    required this.progress,
    required this.powered,
    required this.bossHealth,
    required this.bossMaxHealth,
    required this.phase,
  });

  const GameHudState.initial()
    : health = 3,
      cash = 0,
      progress = 0,
      powered = false,
      bossHealth = 0,
      bossMaxHealth = 6,
      phase = GamePhase.playing;

  final int health;
  final int cash;
  final double progress;
  final bool powered;
  final int bossHealth;
  final int bossMaxHealth;
  final GamePhase phase;

  bool get bossActive => bossHealth > 0;
}
