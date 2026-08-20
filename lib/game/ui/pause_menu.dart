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
          color: const Color(0xF012100C),
          border: Border.all(color: BroskieColors.bone, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("PAUSED",
                style: broskieHeadline(size: 24, color: BroskieColors.bone)),
            const SizedBox(height: 8),
            const Text(
              "THUMBS OFF THE STREET",
              style: TextStyle(
                  color: BroskieColors.amber,
                  fontSize: 12,
                  fontFamily: 'monospace'),
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
              child: const Text("RESUME GAME",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
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
              child: const Text("RESTART LEVEL",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
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
                game.dismissOverlay('PauseMenu');
                game.openShop();
              },
              child: const Text("BLACK MARKET",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1814),
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                BroskieAudio.playUiClick();
                game.returnToTitle();
              },
              child: const Text("TITLE SCREEN",
                  style: TextStyle(
                      color: BroskieColors.bone,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
