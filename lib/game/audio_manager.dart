import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';

class BroskieAudio {
  static bool audioAvailable = false;
  static bool sfxOn = true;
  static bool musicOn = true;

  // Only files that actually exist in assets/audio/. Keep this list honest.
  static const List<String> _sfxFiles = [
    'jump.wav',
    'dash.wav',
    'hit.wav',
    'pickup.wav',
    'powerup.wav',
    'stomp.wav',
    'boss_hit.wav',
    'stage_complete.wav',
    'ui_click.wav',
    'neon_loop.wav',
    'stage1_groove.wav',
    'stage2_slums.wav',
    'stage3_exchange.wav',
    'stage4_core.wav',
  ];

  static const Map<int, String> stageThemes = {
    1: 'stage1_groove.wav',
    2: 'stage2_slums.wav',
    3: 'stage3_exchange.wav',
    4: 'stage4_core.wav',
  };

  static Future<void> init() async {
    try {
      await FlameAudio.audioCache.loadAll(_sfxFiles);
      audioAvailable = true;
    } catch (e) {
      debugPrint("BroskieAudio: Sound files missing or audio disabled: $e");
      audioAvailable = false;
    }
  }

  static void setSfx(bool on) {
    sfxOn = on;
  }

  static void setMusicEnabled(bool on) {
    musicOn = on;
    if (on) {
      startMusic();
    } else {
      stopMusic();
    }
  }

  static void _play(String file, double volume) {
    if (!audioAvailable || !sfxOn) return;
    try {
      FlameAudio.play(file, volume: volume);
    } catch (_) {}
  }

  static void playJump() => _play('jump.wav', 0.5);
  static void playDash() => _play('dash.wav', 0.6);
  static void playHit() => _play('hit.wav', 0.7);
  static void playPickup() => _play('pickup.wav', 0.7);
  static void playPowerup() => _play('powerup.wav', 0.8);
  static void playStomp() => _play('stomp.wav', 0.7);
  static void playBossHit() => _play('boss_hit.wav', 0.8);
  static void playGlitch() => _play('glitch.wav', 0.55);
  static void playStageComplete() => _play('stage_complete.wav', 0.85);
  static void playFanfareS() => _play('fanfare_s.wav', 0.85);
  static void playBossKill() => _play('boss_kill.wav', 0.9);
  static void playUiClick() => _play('ui_click.wav', 0.6);

  static void startMusic() {
    if (audioAvailable && musicOn) {
      try {
        FlameAudio.bgm.play('neon_loop.wav', volume: 0.35);
      } catch (_) {}
    }
  }

  /// Each campaign stage has its own synthesized theme.
  static void playStageTheme(int stage) {
    final file = stageThemes[stage];
    if (file == null || !audioAvailable || !musicOn) return;
    try {
      FlameAudio.bgm.play(file, volume: 0.35);
    } catch (_) {}
  }

  static void stopMusic() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }
}
