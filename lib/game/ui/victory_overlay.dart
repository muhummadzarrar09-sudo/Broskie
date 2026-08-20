import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flutter/material.dart';

class VictoryOverlay extends StatelessWidget {
  final BroskieGame game;

  const VictoryOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BroskieColors.night,
      child: SafeArea(
        child: Center(
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: broskiePanel(border: BroskieColors.amber),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('THE CITY IS YOURS',
                    textAlign: TextAlign.center,
                    style: broskieHeadline(
                        size: 22, color: BroskieColors.amber, letterSpacing: 3)),
                const SizedBox(height: 10),
                const Text(
                  'Monopoly Corp clocked out. Broskie did not.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: BroskieColors.bone,
                      fontSize: 14,
                      fontFamily: 'monospace'),
                ),
                const Divider(color: Color(0x33F2E6D4), height: 28),
                Text('VINYL  ${game.scoreCoins.value}',
                    style: const TextStyle(
                        color: BroskieColors.amber,
                        fontSize: 16,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('STOMPS  ${game.enemiesDefeated}',
                    style: const TextStyle(
                        color: BroskieColors.cap,
                        fontSize: 16,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BroskieColors.amber,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: () {
                      BroskieAudio.playUiClick();
                      game.restart(showLoadCard: true);
                    },
                    child: const Text('PLAY AGAIN',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            letterSpacing: 2)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1814),
                      foregroundColor: BroskieColors.bone,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: const BorderSide(
                            color: BroskieColors.bone, width: 2),
                      ),
                    ),
                    onPressed: () {
                      BroskieAudio.playUiClick();
                      game.returnToTitle();
                    },
                    child: const Text('TITLE SCREEN',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            letterSpacing: 2)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
