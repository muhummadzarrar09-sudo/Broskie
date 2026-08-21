import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class BroskieAudio {
  static bool audioAvailable = false;
  static bool sfxOn = true;
  static bool musicOn = true;
  static double sfxVolume = 1.0;
  static double musicVolume = 1.0;
  /// null = menu loop. Otherwise the last stage theme.
  static int? playingStage;

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
    'glitch.wav',
    'fanfare_s.wav',
    'boss_kill.wav',
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
      _applyMusicVolume();
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
      resumeCurrent();
    } else {
      stopMusic();
    }
  }

  static void setSfxVolume(double v) => sfxVolume = v.clamp(0.0, 1.0);

  static void setMusicVolume(double v) {
    musicVolume = v.clamp(0.0, 1.0);
    _applyMusicVolume();
  }

  /// Pushes the saved level onto the live player. Guarded by [audioAvailable]:
  /// touching FlameAudio.bgm spins up an AudioPlayer, whose platform channel
  /// does not exist in headless tests. That MissingPluginException is thrown
  /// asynchronously, so no try/catch around this call could ever see it — it
  /// would escape into the test zone after the test had already completed.
  static void _applyMusicVolume() {
    if (!audioAvailable) return;
    try {
      FlameAudio.bgm.audioPlayer.setVolume(0.35 * musicVolume);
    } catch (_) {}
  }

  static void resumeCurrent() {
    if (playingStage == null) {
      startMusic();
    } else {
      playStageTheme(playingStage!);
    }
  }

  static void _play(String file, double volume) {
    if (!audioAvailable || !sfxOn || sfxVolume <= 0) return;
    try {
      FlameAudio.play(file, volume: volume * sfxVolume);
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
        FlameAudio.bgm.play('neon_loop.wav', volume: 0.35 * musicVolume);
      } catch (_) {}
    }
  }

  /// Each campaign stage has its own synthesized theme.
  static void playStageTheme(int stage) {
    final file = stageThemes[stage];
    if (file == null || !audioAvailable || !musicOn) return;
    try {
      FlameAudio.bgm.play(file, volume: 0.35 * musicVolume);
    } catch (_) {}
  }

  static void stopMusic() {
    if (!audioAvailable) return;
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }

  static void pauseBgm() {
    if (!audioAvailable) return;
    try {
      FlameAudio.bgm.pause();
    } catch (_) {}
  }

  static void resumeBgm() {
    if (!audioAvailable || !musicOn || musicVolume <= 0) return;
    try {
      FlameAudio.bgm.resume();
    } catch (_) {}
  }
}
