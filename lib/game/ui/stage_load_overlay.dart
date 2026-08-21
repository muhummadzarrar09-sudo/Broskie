import 'dart:async';
import 'dart:math';

import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flutter/material.dart';

/// SMB "WORLD 1-1" card, restyled: stage accent rules frame the smash cut,
/// the zone name slams in the stage color, lives read as pixel hearts, and
/// the executive leaks through on the arena card. The street is already
/// built behind this; we just hold the thumbs until the title reads.
class StageLoadOverlay extends StatefulWidget {
  final BroskieGame game;

  const StageLoadOverlay({super.key, required this.game});

  @override
  State<StageLoadOverlay> createState() => _StageLoadOverlayState();
}

class _StageLoadOverlayState extends State<StageLoadOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  Timer? _timer;
  int _step = 0;

  static const _steps = [
    'LOADING SPRITES',
    'PAVING THE STREET',
    'CUEING THE TUNE',
    "LET'S-A-GO",
  ];

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    Timer.periodic(const Duration(milliseconds: 320), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _step = min(_step + 1, _steps.length - 1));
      if (_step >= _steps.length - 1) t.cancel();
    });
    _timer = Timer(const Duration(milliseconds: 1500), () {
      widget.game.finishStageLoad();
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.game.currentStage.value;
    final info =
        BroskieGame.stageInfo[stage] ?? ('UNKNOWN ZONE', 'SIGNAL LOST');
    final accent = Color(BroskieGame.stageAccents[stage] ?? 0xFF00E5FF);
    final hearts = widget.game.hpMax;

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: BroskieColors.night),
        if (stage == 4)
          // The final card leaks management's face ahead of the arena.
          Opacity(
            opacity: 0.14,
            child: Image.asset(
              'assets/images/runtime/foreman_intro.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        const ScanlineFill(opacity: 0.10),
        // Accent rules top and bottom — the stage color reads the card.
        Positioned(
            top: 0, left: 0, right: 0, child: Container(height: 3, color: accent)),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(height: 3, color: accent)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  'WORLD 1-$stage',
                  style: broskieHeadline(
                      size: 16,
                      color: BroskieColors.amber,
                      letterSpacing: 6),
                ),
                const SizedBox(height: 8),
                CustomPaint(
                  size: const Size(140, 8),
                  painter: _LoadBarcodePainter(accent),
                ),
                const SizedBox(height: 18),
                Text(
                  info.$1,
                  textAlign: TextAlign.center,
                  style: broskieHeadline(
                      size: 40, color: accent, letterSpacing: 6),
                ),
                const SizedBox(height: 6),
                Text(
                  info.$2,
                  style: const TextStyle(
                      color: Color(0xB3F2E6D4),
                      fontFamily: 'monospace',
                      letterSpacing: 3,
                      fontSize: 11,
                      fontStyle: FontStyle.italic),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'BROSKIE  ×',
                      style: TextStyle(
                          color: BroskieColors.bone,
                          fontFamily: 'monospace',
                          fontSize: 15,
                          fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 10),
                    for (var i = 0; i < hearts; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      const CustomPaint(
                        size: Size(21, 16),
                        painter: PixelHeartPainter(filled: true),
                      ),
                    ],
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _spin,
                      builder: (context, _) => Transform.rotate(
                        angle: _spin.value * 2 * pi,
                        child: const CustomPaint(
                          size: Size(30, 30),
                          painter: PixelVinylPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _steps[_step],
                      style: const TextStyle(
                          color: BroskieColors.amber,
                          fontFamily: 'monospace',
                          letterSpacing: 3,
                          fontSize: 12,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The card's stamp, printed in the stage's own accent color.
class _LoadBarcodePainter extends CustomPainter {
  final Color color;

  const _LoadBarcodePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    drawBarcode(canvas, Offset.zero & size, seed: 700, color: color);
  }

  @override
  bool shouldRepaint(_LoadBarcodePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Tiny "BROSKIE × N" wipe after a fall, SMB lives screen.
class DeathCardOverlay extends StatefulWidget {
  final BroskieGame game;

  const DeathCardOverlay({super.key, required this.game});

  @override
  State<DeathCardOverlay> createState() => _DeathCardOverlayState();
}

class _DeathCardOverlayState extends State<DeathCardOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 800), () {
      widget.game.hideDeathCard();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BroskieColors.night,
      child: Center(
        child: Text(
          'BROSKIE  ×  ${widget.game.hp.value}',
          style: broskieHeadline(size: 28, letterSpacing: 4),
        ),
      ),
    );
  }
}
