class BandwidthManager {
  static double currentBandwidth = 100.0;
  static const double maxBandwidth = 100.0;
  static const double drainRate = 5.0; // Per second underwater

  static void update(double dt, bool isUnderwater) {
    if (isUnderwater) {
      currentBandwidth -= drainRate * dt;
      if (currentBandwidth <= 0) {
        currentBandwidth = 0;
        _triggerPacketLoss();
      }
    } else {
      // Recharge
      currentBandwidth = (currentBandwidth + drainRate * 2 * dt).clamp(0, maxBandwidth);
    }
  }

  static void _triggerPacketLoss() {
    print("CRITICAL PACKET LOSS! Broskie is drowning in data!");
    // Damage player
  }
}
