import 'dart:math';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/audio_manager.dart';

class MainMenuOverlay extends StatefulWidget {
  final BroskieGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay> with TickerProviderStateMixin {
  // Drives the endless ambience: art sway, breathing zoom, rain, title float.
  late final AnimationController _ambience;
  // One-shot entrance: title drops in, buttons stagger up.
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _ambience = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  }

  @override
  void dispose() {
    _ambience.dispose();
    _entrance.dispose();
    super.dispose();
  }

  /// Staggered slide-up + fade used by every menu element.
  Widget _slideIn(int order, Widget child) {
    final start = (order * 0.12).clamp(0.0, 0.6);
    final t = ((_entrance.value - start) / (1 - start)).clamp(0.0, 1.0);
    final eased = 1 - pow(1 - t, 3).toDouble(); // easeOutCubic
    return Opacity(
      opacity: eased,
      child: Transform.translate(offset: Offset(0, 26 * (1 - eased)), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_ambience, _entrance]),
      builder: (context, _) {
        final sway = sin(_ambience.value * 2 * pi); // -1..1 over 8s
        final breathe = 1.065 + 0.012 * sway;
        final float = 4 * sin(_ambience.value * 2 * pi);

        return SizedBox.expand(
          child: Stack(
            children: [
              // Rooftop key art with a gentle sway + breath.
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(sway * 16, 0),
                  child: Transform.scale(
                    scale: breathe,
                    child: Image.asset(
                      'assets/images/runtime/menu_keyart.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.none, // crisp pixels
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFA0F0C20), Color(0xFA241244)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Readability scrim over the art
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.35), Colors.black.withOpacity(0.62)],
                    ),
                  ),
                ),
              ),

              // Procedural rain — pure code, no asset.
              Positioned.fill(
                child: CustomPaint(painter: _MenuRainPainter(_ambience.value)),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _slideIn(
                    0,
                    Transform.translate(
                      offset: Offset(0, float),
                      child: Text(
                        "BROSKIE",
                        style: TextStyle(
                          color: const Color(0xFF00E5FF),
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                          letterSpacing: 8,
                          shadows: [
                            const Shadow(color: Colors.black, blurRadius: 24),
                            Shadow(color: const Color(0xFF00E5FF), blurRadius: 26 + 8 * sway.abs()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _slideIn(
                    1,
                    const Text(
                      "MONOPOLY CORP MUST FALL",
                      style: TextStyle(color: Colors.amber, fontSize: 16, fontStyle: FontStyle.italic, fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 48),
                  ValueListenableBuilder<int>(
                    valueListenable: widget.game.unlockedStage,
                    builder: (context, unlocked, _) => Column(
                      children: [
                        if (unlocked > 1) ...[
                          _slideIn(2, _menuButton("CONTINUE — STAGE $unlocked", Colors.amber, Colors.black, () => widget.game.startRun(unlocked))),
                          const SizedBox(height: 14),
                        ],
                        _slideIn(3, _menuButton("NEW RUN", const Color(0xFF00E5FF), Colors.black, () => widget.game.startRun(1))),
                        const SizedBox(height: 14),
                        _slideIn(4, _menuButton("STAGE SELECT", Colors.white24, Colors.white, () => widget.game.overlays.add('LevelSelect'))),
                        const SizedBox(height: 14),
                        _slideIn(5, _menuButton("SETTINGS", Colors.white24, Colors.white, () => widget.game.overlays.add('Settings'))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  _slideIn(
                    6,
                    const Text(
                      "CODE + AI ART · BUILT FOR THE CREW",
                      style: TextStyle(color: Colors.white24, fontSize: 11, fontFamily: 'monospace', letterSpacing: 2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _menuButton(String label, Color bg, Color fg, VoidCallback onTap) {
    return SizedBox(
      width: 280,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          BroskieAudio.playUiClick();
          onTap();
        },
        child: Text(
          label,
          style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'monospace', letterSpacing: 2),
        ),
      ),
    );
  }
}

/// Deterministic streaks of neon rain. Phase [t] loops 0..1 forever.
class _MenuRainPainter extends CustomPainter {
  final double t;

  _MenuRainPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 90; i++) {
      // Stable pseudo-random per drop
      final seedX = (i * 97.31) % 1.0;
      final seedSpeed = 0.55 + (i % 5) * 0.13;
      final seedLean = ((i * 37.77) % 1.0 - 0.5) * 0.4;
      final brightness = i % 7 == 0 ? 0.34 : 0.16; // a few hero streaks

      final cycle = (t * seedSpeed + i * 0.61803) % 1.0;
      final x = seedX * size.width + seedLean * cycle * size.height;
      final y = cycle * size.height * 1.1 - size.height * 0.05;

      paint.color = (i % 9 == 0 ? const Color(0xFF00E5FF) : Colors.white).withOpacity(brightness);
      canvas.drawLine(Offset(x, y), Offset(x - seedLean * 14, y - 13), paint);
    }
  }

  @override
  bool shouldRepaint(_MenuRainPainter oldDelegate) => oldDelegate.t != t;
}
