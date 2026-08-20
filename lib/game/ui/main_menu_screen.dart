import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/difficulty.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flutter/material.dart';

class MainMenuOverlay extends StatelessWidget {
  final BroskieGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BroskieColors.night,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('BROSKIE',
                      style: broskieHeadline(
                          size: 56,
                          color: BroskieColors.bone,
                          letterSpacing: 8)),
                  const SizedBox(height: 6),
                  const Text(
                    'A KID. A VINYL. A BAD ATTITUDE.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BroskieColors.amber,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ValueListenableBuilder<BroskieDifficulty>(
                    valueListenable: game.difficulty,
                    builder: (context, current, _) => Row(
                      children: BroskieDifficulty.values.map((d) {
                        final on = d == current;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () {
                                BroskieAudio.playUiClick();
                                game.difficulty.value = d;
                                game.savePrefs();
                              },
                              child: Container(
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: on
                                      ? BroskieColors.amber
                                      : const Color(0xFF1A1814),
                                  border: Border.all(
                                      color: BroskieColors.bone, width: 2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  d.label,
                                  style: TextStyle(
                                    color: on
                                        ? Colors.black
                                        : BroskieColors.bone,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<BroskieDifficulty>(
                    valueListenable: game.difficulty,
                    builder: (context, d, _) => Text(
                      '${d.hearts} HEART${d.hearts == 1 ? '' : 'S'}',
                      style: const TextStyle(
                          color: Color(0x99F2E6D4),
                          fontFamily: 'monospace',
                          fontSize: 11,
                          letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 22),
                  ValueListenableBuilder<int>(
                    valueListenable: game.unlockedStage,
                    builder: (context, unlocked, _) => Column(
                      children: [
                        if (unlocked > 1) ...[
                          _btn('CONTINUE  STAGE $unlocked', BroskieColors.amber,
                              Colors.black, () => game.startRun(unlocked)),
                          const SizedBox(height: 12),
                        ],
                        _btn('NEW RUN', BroskieColors.bone, Colors.black,
                            () => game.startRun(1)),
                        const SizedBox(height: 12),
                        _btn('STAGE SELECT', const Color(0xFF1A1814),
                            BroskieColors.bone, game.openLevelSelect),
                        const SizedBox(height: 12),
                        _btn('SETTINGS', const Color(0xFF1A1814),
                            BroskieColors.bone, game.openSettings),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ANDROID  ·  TOUCH  ·  HOLD A TO FLOAT',
                    style: TextStyle(
                        color: Color(0x66F2E6D4),
                        fontFamily: 'monospace',
                        fontSize: 10,
                        letterSpacing: 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _btn(String label, Color bg, Color fg, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: BroskieColors.bone, width: 2),
          ),
        ),
        onPressed: () {
          BroskieAudio.playUiClick();
          onTap();
        },
        child: Text(
          label,
          style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              letterSpacing: 2),
        ),
      ),
    );
  }
}
