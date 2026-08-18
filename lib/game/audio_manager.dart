import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';

class BroskieAudio {
  static bool audioAvailable = false;

  static Future<void> init() async {
    try {
      await FlameAudio.audioCache.loadAll([
        'jump.wav',
        'stomp.wav',
        'powerup.wav',
        'hit.wav',
        'hell_na.wav',
        'drone_hum.wav',
        'glitch_static.wav',
        'boss_theme_w1.mp3',
        'boss_theme_w2.mp3',
      ]);
      audioAvailable = true;
    } catch (e) {
      debugPrint("BroskieAudio: Sound files missing or audio disabled: $e");
      audioAvailable = false;
    }
  }

  static void playJump() {
    if (audioAvailable) {
      try { FlameAudio.play('jump.wav', volume: 0.5); } catch (_) {}
    }
  }

  static void playStomp() {
    if (audioAvailable) {
      try { FlameAudio.play('stomp.wav', volume: 0.7); } catch (_) {}
    }
  }

  static void playPowerup() {
    if (audioAvailable) {
      try { FlameAudio.play('powerup.wav', volume: 0.8); } catch (_) {}
    }
  }

  static void playDrone() {
    if (audioAvailable) {
      try { FlameAudio.play('drone_hum.wav', volume: 0.3); } catch (_) {}
    }
  }

  static void playGlitch() {
    if (audioAvailable) {
      try { FlameAudio.play('glitch_static.wav', volume: 0.5); } catch (_) {}
    }
  }

  static void playHellNa() {
    if (audioAvailable) {
      try { FlameAudio.play('hell_na.wav', volume: 0.8); } catch (_) {}
    }
  }

  static void startMusic() {
    if (audioAvailable) {
      try { FlameAudio.bgm.play('main_theme.mp3', volume: 0.3); } catch (_) {}
    }
  }
}
