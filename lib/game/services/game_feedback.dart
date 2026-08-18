import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum FeedbackCue {
  jump,
  dash,
  pickup,
  stomp,
  hit,
  powerUp,
  bossHit,
  stageComplete,
  ui,
}

abstract class GameFeedback {
  Future<void> initialize({required bool audioEnabled});

  void setAudioEnabled(bool enabled);

  void emit(FeedbackCue cue, {required bool hapticsEnabled});

  Future<void> dispose();
}

class DeviceGameFeedback implements GameFeedback {
  static const _sounds = <FeedbackCue, String>{
    FeedbackCue.jump: 'jump.wav',
    FeedbackCue.dash: 'dash.wav',
    FeedbackCue.pickup: 'pickup.wav',
    FeedbackCue.stomp: 'stomp.wav',
    FeedbackCue.hit: 'hit.wav',
    FeedbackCue.powerUp: 'powerup.wav',
    FeedbackCue.bossHit: 'boss_hit.wav',
    FeedbackCue.stageComplete: 'stage_complete.wav',
    FeedbackCue.ui: 'ui_click.wav',
  };

  bool _audioEnabled = true;
  bool _musicPlaying = false;
  bool _initialized = false;

  @override
  Future<void> initialize({required bool audioEnabled}) async {
    _audioEnabled = audioEnabled;
    try {
      await FlameAudio.audioCache.loadAll([..._sounds.values, 'neon_loop.wav']);
      _initialized = true;
      if (_audioEnabled) {
        await _startMusic();
      }
    } catch (error) {
      debugPrint('Audio initialization skipped: $error');
    }
  }

  @override
  void setAudioEnabled(bool enabled) {
    _audioEnabled = enabled;
    if (!_initialized) {
      return;
    }
    if (enabled) {
      unawaited(_startMusic());
    } else {
      _musicPlaying = false;
      unawaited(FlameAudio.bgm.stop());
    }
  }

  @override
  void emit(FeedbackCue cue, {required bool hapticsEnabled}) {
    if (_audioEnabled && _initialized) {
      final sound = _sounds[cue];
      if (sound != null) {
        unawaited(_playSafely(sound, _volumeFor(cue)));
      }
    }
    if (hapticsEnabled) {
      unawaited(_hapticSafely(cue));
    }
  }

  Future<void> _startMusic() async {
    if (_musicPlaying || !_audioEnabled) {
      return;
    }
    try {
      _musicPlaying = true;
      await FlameAudio.bgm.play('neon_loop.wav', volume: 0.16);
    } catch (error) {
      _musicPlaying = false;
      debugPrint('Background music skipped: $error');
    }
  }

  Future<void> _playSafely(String sound, double volume) async {
    try {
      await FlameAudio.play(sound, volume: volume);
    } catch (error) {
      debugPrint('Sound $sound skipped: $error');
    }
  }

  Future<void> _hapticSafely(FeedbackCue cue) async {
    try {
      switch (cue) {
        case FeedbackCue.pickup:
        case FeedbackCue.ui:
          await HapticFeedback.selectionClick();
        case FeedbackCue.jump:
        case FeedbackCue.dash:
        case FeedbackCue.powerUp:
          await HapticFeedback.mediumImpact();
        case FeedbackCue.stomp:
        case FeedbackCue.bossHit:
          await HapticFeedback.heavyImpact();
        case FeedbackCue.hit:
        case FeedbackCue.stageComplete:
          await HapticFeedback.vibrate();
      }
    } catch (error) {
      debugPrint('Haptic feedback skipped: $error');
    }
  }

  double _volumeFor(FeedbackCue cue) {
    switch (cue) {
      case FeedbackCue.jump:
      case FeedbackCue.ui:
        return 0.35;
      case FeedbackCue.pickup:
        return 0.42;
      case FeedbackCue.dash:
      case FeedbackCue.powerUp:
        return 0.5;
      case FeedbackCue.stomp:
      case FeedbackCue.hit:
      case FeedbackCue.bossHit:
        return 0.58;
      case FeedbackCue.stageComplete:
        return 0.65;
    }
  }

  @override
  Future<void> dispose() async {
    _musicPlaying = false;
    try {
      await FlameAudio.bgm.stop();
    } catch (error) {
      debugPrint('Audio shutdown skipped: $error');
    }
  }
}

class SilentGameFeedback implements GameFeedback {
  @override
  Future<void> initialize({required bool audioEnabled}) async {}

  @override
  void setAudioEnabled(bool enabled) {}

  @override
  void emit(FeedbackCue cue, {required bool hapticsEnabled}) {}

  @override
  Future<void> dispose() async {}
}
