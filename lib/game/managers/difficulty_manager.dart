class AdaptiveDifficulty {
  static int retryCount = 0;
  static double bossStartTime = 0;
  
  static void logRetry() {
    retryCount++;
    print("Retry Count: $retryCount");
  }

  static bool shouldTriggerGlitch(double currentBossHealth, double maxHealth) {
    // If boss is losing health too fast (too easy)
    double timeElapsed = DateTime.now().millisecondsSinceEpoch / 1000 - bossStartTime;
    double healthPercent = currentBossHealth / maxHealth;

    if (healthPercent < 0.5 && timeElapsed < 30) {
      return true; // Boss is dying too fast! Trigger a glitch/fake-out
    }

    // If player is retrying too much, maybe trigger a 'Helpful' glitch
    if (retryCount > 5) {
      return true; 
    }

    return false;
  }
}
