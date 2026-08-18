import 'package:flutter/material.dart';
import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';

class SettingsOverlay extends StatelessWidget {
  final BroskieGame game;

  const SettingsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          border: Border.all(color: const Color(0xFF00E5FF), width: 4),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0xFF00E5FF), blurRadius: 15)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "SYSTEM SETTINGS",
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const Divider(color: Colors.white24, height: 20),

            ValueListenableBuilder<bool>(
              valueListenable: game.sfxEnabled,
              builder: (context, on, _) => SwitchListTile(
                activeColor: const Color(0xFF00E5FF),
                title: const Text("Sound FX", style: TextStyle(color: Colors.white)),
                value: on,
                onChanged: (v) {
                  game.sfxEnabled.value = v;
                  BroskieAudio.setSfx(v);
                  game.savePrefs();
                },
              ),
            ),

            ValueListenableBuilder<bool>(
              valueListenable: game.musicEnabled,
              builder: (context, on, _) => SwitchListTile(
                activeColor: const Color(0xFF00E5FF),
                title: const Text("Music", style: TextStyle(color: Colors.white)),
                value: on,
                onChanged: (v) {
                  game.musicEnabled.value = v;
                  BroskieAudio.setMusicEnabled(v);
                  game.savePrefs();
                },
              ),
            ),

            ValueListenableBuilder<bool>(
              valueListenable: game.touchControlsEnabled,
              builder: (context, on, _) => SwitchListTile(
                activeColor: const Color(0xFF00E5FF),
                title: const Text("Touch Controls", style: TextStyle(color: Colors.white)),
                value: on,
                onChanged: (v) {
                  game.touchControlsEnabled.value = v;
                  game.savePrefs();
                },
              ),
            ),

            const SizedBox(height: 10),
            ValueListenableBuilder<double>(
              valueListenable: game.shakeScale,
              builder: (context, scale, _) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Screen Shake", style: TextStyle(color: Colors.white)),
                      Text("${(scale * 100).toInt()}%", style: const TextStyle(color: Colors.amber)),
                    ],
                  ),
                  Slider(
                    activeColor: Colors.amber,
                    value: scale,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    onChanged: (v) {
                      game.shakeScale.value = v;
                      game.savePrefs();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
              onPressed: () => game.overlays.remove('Settings'),
              child: const Text("SAVE & EXIT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
