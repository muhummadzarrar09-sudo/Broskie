import 'dart:async';
import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/difficulty.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flutter/material.dart';

/// Title as an attract-mode street: Broskie walks the lower third,
/// same silhouette the in-game camera uses.
class MainMenuOverlay extends StatefulWidget {
  final BroskieGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _walk;

  @override
  void initState() {
    super.initState();
    _walk =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();
  }

  @override
  void dispose() {
    _walk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return ColoredBox(
      color: BroskieColors.night,
      child: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
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
                                size: 52,
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
                        const SizedBox(height: 22),
                        ValueListenableBuilder<BroskieDifficulty>(
                          valueListenable: game.difficulty,
                          builder: (context, current, _) => Row(
                            children: BroskieDifficulty.values.map((d) {
                              final on = d == current;
                              return Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: GestureDetector(
                                    onTap: () {
                                      BroskieAudio.playUiClick();
                                      game.difficulty.value = d;
                                      unawaited(game.savePrefs());
                                    },
                                    child: Container(
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: on
                                            ? BroskieColors.amber
                                            : const Color(0xFF1A1814),
                                        border: Border.all(
                                            color: BroskieColors.bone,
                                            width: 2),
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
                        const SizedBox(height: 6),
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
                        const SizedBox(height: 18),
                        ValueListenableBuilder<int>(
                          valueListenable: game.unlockedStage,
                          builder: (context, unlocked, _) => Column(
                            children: [
                              if (unlocked > 1) ...[
                                _btn(
                                    'CONTINUE  STAGE $unlocked',
                                    BroskieColors.amber,
                                    Colors.black,
                                    () => game.startRun(unlocked)),
                                const SizedBox(height: 10),
                              ],
                              _btn(
                                  'NEW RUN',
                                  BroskieColors.bone,
                                  Colors.black,
                                  () => game.startRun(1, newRun: true)),
                              const SizedBox(height: 10),
                              _btn('STAGE SELECT', const Color(0xFF1A1814),
                                  BroskieColors.bone, game.openLevelSelect),
                              const SizedBox(height: 10),
                              _btn('SETTINGS', const Color(0xFF1A1814),
                                  BroskieColors.bone, game.openSettings),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 96,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _walk,
              builder: (context, _) =>
                  CustomPaint(painter: _AttractStreetPainter(_walk.value)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(String label, Color bg, Color fg, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 44,
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

class _AttractStreetPainter extends CustomPainter {
  final double t;

  _AttractStreetPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF222533));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 6),
        Paint()..color = BroskieColors.bone);
    // Ping-pong walk across the lip.
    final ping = t < 0.5 ? t * 2 : (1 - t) * 2;
    final x = 20 + (size.width - 56) * ping;
    const y = 14.0;
    canvas.drawRect(
        Rect.fromLTWH(x, y, 20, 12), Paint()..color = BroskieColors.bone);
    canvas.drawRect(
        Rect.fromLTWH(x - 2, y - 5, 24, 7), Paint()..color = BroskieColors.cap);
    canvas.drawRect(Rect.fromLTWH(x + 2, y + 12, 16, 22),
        Paint()..color = const Color(0xFF1F4287));
  }

  @override
  bool shouldRepaint(_AttractStreetPainter oldDelegate) => oldDelegate.t != t;
}
