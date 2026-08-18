import 'package:flutter/material.dart';
import 'package:broskie_game/game/broskie_game.dart';

class SettingsOverlay extends StatefulWidget {
  final BroskieGame game;

  const SettingsOverlay({super.key, required this.game});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  bool sfxEnabled = true;
  bool touchControlsEnabled = true;
  double shakeScale = 1.0;

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

            SwitchListTile(
              activeColor: const Color(0xFF00E5FF),
              title: const Text("Sound FX", style: TextStyle(color: Colors.white)),
              value: sfxEnabled,
              onChanged: (val) => setState(() => sfxEnabled = val),
            ),

            SwitchListTile(
              activeColor: const Color(0xFF00E5FF),
              title: const Text("Touch Controls", style: TextStyle(color: Colors.white)),
              value: touchControlsEnabled,
              onChanged: (val) => setState(() => touchControlsEnabled = val),
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Screen Shake", style: TextStyle(color: Colors.white)),
                Text("${(shakeScale * 100).toInt()}%", style: const TextStyle(color: Colors.amber)),
              ],
            ),
            Slider(
              activeColor: Colors.amber,
              value: shakeScale,
              onChanged: (val) => setState(() => shakeScale = val),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
              onPressed: () => widget.game.overlays.remove('Settings'),
              child: const Text("SAVE & EXIT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
