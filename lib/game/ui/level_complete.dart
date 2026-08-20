import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flutter/material.dart';

class LevelCompleteOverlay extends StatelessWidget {
  final int coins;
  final int enemiesStomped;
  final String rank;
  final String bestRank;
  final VoidCallback onNextLevel;
  final bool isLastStage;

  const LevelCompleteOverlay({
    super.key,
    required this.coins,
    required this.enemiesStomped,
    required this.rank,
    required this.bestRank,
    required this.onNextLevel,
    this.isLastStage = false,
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
        decoration: broskiePanel(border: BroskieColors.amber),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("LEVEL CLEARED!",
                style: broskieHeadline(size: 24, color: BroskieColors.amber)),
            const SizedBox(height: 6),
            const Text(
              "HELL NAAAAA, BROSKIE COOKED!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 14),

            // Big performance rank — an S certifies you a GOLD RECORD.
            if (rank == 'S')
              const _GoldRecordBadge()
            else
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _rankColor, width: 5),
                  boxShadow: [
                    BoxShadow(
                        color: _rankColor.withValues(alpha: 0.5),
                        blurRadius: 18)
                  ],
                ),
                child: Center(
                  child: Text(
                    rank,
                    style: TextStyle(
                        color: _rankColor,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace'),
                  ),
                ),
              ),
            if (rank == 'S')
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "★ GOLD RECORD · NO DAMAGE · UNDER PAR ★",
                  style: TextStyle(
                      color: BroskieColors.amber,
                      fontSize: 10,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              "BEST: $bestRank",
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontFamily: 'monospace',
                  letterSpacing: 2),
            ),

            const Divider(color: Colors.white24, height: 24),
            Text("VINYL $coins",
                style:
                    const TextStyle(color: Colors.greenAccent, fontSize: 18)),
            Text("STOMPS: $enemiesStomped",
                style: const TextStyle(color: Colors.redAccent, fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                BroskieAudio.playUiClick();
                onNextLevel();
              },
              child: Text(isLastStage ? "TAKE THE CITY" : "NEXT LEVEL",
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

/// S-rank trophy: a gold 7-inch. Grooves, sheen, magenta center label.
class _GoldRecordBadge extends StatelessWidget {
  const _GoldRecordBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFFF3C4),
            BroskieColors.amber,
            Color(0xFF8D6E1F),
            BroskieColors.amber
          ],
          stops: [0.0, 0.35, 0.72, 1.0],
        ),
        border: Border.all(color: const Color(0xFFFFF3C4), width: 2),
        boxShadow: [
          BoxShadow(
              color: BroskieColors.amber.withValues(alpha: 0.75),
              blurRadius: 26,
              spreadRadius: 2),
        ],
      ),
      child: Center(
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
            border: Border.all(
                color: BroskieColors.bone.withValues(alpha: 0.6), width: 1.5),
          ),
          child: const Center(
            child: Text(
              'S',
              style: TextStyle(
                  color: BroskieColors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace'),
            ),
          ),
        ),
      ),
    );
  }
}
