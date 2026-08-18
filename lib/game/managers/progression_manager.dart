class ProgressionManager {
  static bool creativeModeUnlocked = false;
  static bool bossRushUnlocked = false;

  static void unlockEndGame() {
    creativeModeUnlocked = true;
    bossRushUnlocked = true;
    print("ALL 56 LEVELS CLEARED! Creative Mode & Boss Rush UNLOCKED!");
  }
}

class Skin {
  final String id;
  final String name;
  final double speedMult;
  final double jumpMult;

  Skin(this.id, this.name, {this.speedMult = 1.0, this.jumpMult = 1.0});
}

class WeaponUpgrade {
  final String category;
  int level;
  final int maxLevel = 5;

  WeaponUpgrade(this.category, {this.level = 0});

  int get upgradeCost => (level + 1) * 500;

  void upgrade() {
    if (level < maxLevel) level++;
  }
}

class WeaponManager {
  static List<WeaponUpgrade> upgrades = [
    WeaponUpgrade('Piercing'),
    WeaponUpgrade('Explosive'),
    WeaponUpgrade('Electric'),
  ];

  static WeaponUpgrade getUpgrade(String category) {
    return upgrades.firstWhere((u) => u.category == category);
  }
}
