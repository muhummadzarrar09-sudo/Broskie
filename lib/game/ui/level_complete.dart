import 'package:flutter/material.dart';
import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';

class LevelCompleteOverlay extends StatelessWidget {
  final int coins;
  final int enemiesStomped;
  final String rank;
  final String bestRank;
  final VoidCallback onNextLevel;

  const LevelCompleteOverlay({
    super.key,
    required this.coins,
    required this.enemiesStomped,
    required this.rank,
    required this.bestRank,
    required this.onNextLevel,
  });

  Color get _rankColor => switch (rank) {
        'S' => Colors.amber,
        'A' => Colors.cyanAccent,
        'B' => Colors.greenAccent,
        _ => Colors.white70,
      };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.92),
          border: Border.all(color: Colors.amber, width: 4),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: _rankColor.withOpacity(0.6), blurRadius: 24)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("LEVEL CLEARED!", style: broskieHeadline(size: 24, color: BroskieColors.amber)),
            const SizedBox(height: 6),
            const Text(
              "HELL NAAAAA, BROSKIE COOKED!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 15, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 14),

            // Big performance rank
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _rankColor, width: 5),
                boxShadow: [BoxShadow(color: _rankColor.withOpacity(0.5), blurRadius: 18)],
              ),
              child: Center(
                child: Text(
                  rank,
                  style: TextStyle(color: _rankColor, fontSize: 52, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "BEST: $bestRank",
              style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'monospace', letterSpacing: 2),
            ),

            const Divider(color: Colors.white24, height: 24),
            Text("CASH: \$$coins", style: const TextStyle(color: Colors.greenAccent, fontSize: 18)),
            Text("EXECUTIVES DOWN: $enemiesStomped", style: const TextStyle(color: Colors.redAccent, fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                BroskieAudio.playUiClick();
                onNextLevel();
              },
              child: const Text("NEXT LEVEL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
