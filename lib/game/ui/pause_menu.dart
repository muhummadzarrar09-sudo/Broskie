import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flutter/material.dart';

class PauseMenuOverlay extends StatelessWidget {
  final BroskieGame game;

  const PauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.95),
          border: Border.all(color: const Color(0xFF00E5FF), width: 4),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0xFF00E5FF), blurRadius: 15)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("SYSTEM PAUSED", style: broskieHeadline(size: 24)),
            const SizedBox(height: 8),
            const Text(
              "BROSKIE CORP OVERRIDE",
              style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'monospace'),
            ),
            const Divider(color: Colors.white24, height: 30),

            // Resume Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () {
                BroskieAudio.playUiClick();
                game.togglePause();
              },
              child: const Text("RESUME GAME", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),

            // Restart Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () {
                BroskieAudio.playUiClick();
                game.togglePause();
                game.restart();
              },
              child: const Text("RESTART LEVEL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),

            // Open Shop
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BroskieColors.magenta,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () {
                BroskieAudio.playUiClick();
                game.togglePause();
                game.overlays.add('Shop');
              },
              child: const Text("BLACK MARKET SHOP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
