/// Mario-shaped difficulty. Chosen on the title screen, persisted on-device.
enum BroskieDifficulty {
  easy,
  normal,
  hard;

  String get label => switch (this) {
        easy => 'EASY',
        normal => 'NORMAL',
        hard => 'HARD',
      };

  /// Hearts at the start of a run. Hard is small-Mario: one hit.
  int get hearts => switch (this) {
        easy => 5,
        normal => 3,
        hard => 1,
      };

  double get enemySpeed => switch (this) {
        easy => 0.75,
        normal => 1.0,
        hard => 1.35,
      };

  double get coyoteTime => switch (this) {
        easy => 0.16,
        normal => 0.10,
        hard => 0.06,
      };

  double get jumpBuffer => switch (this) {
        easy => 0.18,
        normal => 0.12,
        hard => 0.08,
      };

  double get iFrameSeconds => switch (this) {
        easy => 2.0,
        normal => 1.5,
        hard => 1.1,
      };

  static BroskieDifficulty fromName(String? name) {
    return BroskieDifficulty.values.firstWhere(
      (d) => d.name == name,
      orElse: () => BroskieDifficulty.normal,
    );
  }
}
