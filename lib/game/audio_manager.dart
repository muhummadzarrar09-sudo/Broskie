import 'package:flame_audio/flame_audio.dart';

class BroskieAudio {
  static Future<void> init() async {
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
  }

  static void playDrone() => FlameAudio.play('drone_hum.wav', volume: 0.3);
  static void playGlitch() => FlameAudio.play('glitch_static.wav', volume: 0.5);
  
  static void playHellNa() {
    // Random chance or triggered on fail
    FlameAudio.play('hell_na.wav', volume: 0.8);
  }

  static void startMusic() {
    FlameAudio.bgm.play('main_theme.mp3', volume: 0.3);
  }
}
