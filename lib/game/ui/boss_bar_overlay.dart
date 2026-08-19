import 'package:flutter/material.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';

/// Fighting-game boss nameplate: amber frame, draining red core,
/// boss serial name lit up like a marque. Lives at the top of the HUD.
class BossBarOverlay extends StatelessWidget {
  final BroskieGame game;

  const BossBarOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.88),
        child: Container(
          width: 430,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: broskiePanel(border: BroskieColors.amber),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(game.bossBarName, style: broskieHeadline(size: 15, color: BroskieColors.amber, letterSpacing: 3)),
                  const Spacer(),
                  const Text('EXECUTIVE', style: TextStyle(color: BroskieColors.bone, fontSize: 9, fontFamily: 'monospace', letterSpacing: 3)),
                ],
              ),
              const SizedBox(height: 6),
              ValueListenableBuilder<double>(
                valueListenable: game.bossBar,
                builder: (context, frac, child) {
                  final f = frac.clamp(0.0, 1.0);
                  return Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: BroskieColors.bone, width: 2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: f,
                      child: Container(
                        color: f > 0.5
                            ? const Color(0xFFFF5252)
                            : (f > 0.25 ? BroskieColors.amber : BroskieColors.magenta),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The white frame on the killing blow. Always registered; invisible at zero.
class ScreenFlashOverlay extends StatelessWidget {
  final BroskieGame game;

  const ScreenFlashOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<double>(
        valueListenable: game.screenFlash,
        builder: (context, v, child) => v <= 0
            ? const SizedBox.shrink()
            : Container(color: Colors.white.withOpacity(v.clamp(0.0, 1.0))),
      ),
    );
  }
}
