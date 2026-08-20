import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flutter/material.dart';

class GameOverOverlay extends StatelessWidget {
  final VoidCallback onRestart;

  const GameOverOverlay({super.key, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BroskieColors.night,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('BROSKIE  ×  0',
                  style: broskieHeadline(
                      size: 32, color: BroskieColors.cap, letterSpacing: 4)),
              const SizedBox(height: 12),
              const Text(
                'DOWN, NOT OUT.',
                style: TextStyle(
                    color: BroskieColors.amber,
                    fontFamily: 'monospace',
                    letterSpacing: 3,
                    fontSize: 13),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 260,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BroskieColors.amber,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: onRestart,
                  child: const Text('GO BACK IN',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
