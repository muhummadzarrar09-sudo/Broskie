/// Mario-shaped difficulty. Chosen on the title screen, persisted on-device.
enum BroskieDifficulty { easy, normal, hard }

extension BroskieDifficultyTuning on BroskieDifficulty {
  String get label => switch (this) {
        BroskieDifficulty.easy => 'EASY',
        BroskieDifficulty.normal => 'NORMAL',
        BroskieDifficulty.hard => 'HARD',
      };

  /// Hearts at the start of a run. Hard is small-Mario: one hit.
  int get hearts => switch (this) {
        BroskieDifficulty.easy => 5,
        BroskieDifficulty.normal => 3,
        BroskieDifficulty.hard => 1,
      };

  double get enemySpeed => switch (this) {
        BroskieDifficulty.easy => 0.75,
        BroskieDifficulty.normal => 1.0,
        BroskieDifficulty.hard => 1.35,
      };

  double get coyoteTime => switch (this) {
        BroskieDifficulty.easy => 0.16,
        BroskieDifficulty.normal => 0.10,
        BroskieDifficulty.hard => 0.06,
      };

  double get jumpBuffer => switch (this) {
        BroskieDifficulty.easy => 0.18,
        BroskieDifficulty.normal => 0.12,
        BroskieDifficulty.hard => 0.08,
      };

  double get iFrameSeconds => switch (this) {
        BroskieDifficulty.easy => 2.0,
        BroskieDifficulty.normal => 1.5,
        BroskieDifficulty.hard => 1.1,
      };

  static BroskieDifficulty fromName(String? name) {
    return BroskieDifficulty.values.firstWhere(
      (d) => d.name == name,
      orElse: () => BroskieDifficulty.normal,
    );
  }
}
