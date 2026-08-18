import 'package:flutter/material.dart';
import 'package:broskie_game/game/broskie_game.dart';

class VictoryOverlay extends StatelessWidget {
  final BroskieGame game;

  const VictoryOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          border: Border.all(color: Colors.amber, width: 5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.amber, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
            const SizedBox(height: 10),
            const Text(
              "NEO-CITY LIBERATED!",
              style: TextStyle(
                color: Colors.amber,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Broskie Corp takeover complete! Monopoly standardization is OVER!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const Divider(color: Colors.white24, height: 30),

            Text("TOTAL CASH: \$$game.scoreCoins", style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("EXECUTIVES DEFEATED: ${game.enemiesDefeated}", style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: () => game.restart(),
              child: const Text("PLAY AGAIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
