import 'dart:async';
import 'dart:math';

import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flutter/material.dart';

/// SMB "WORLD 1-1" card. The street is already built behind this;
/// we just hold the thumbs until the title reads.
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
    final hearts = widget.game.hpMax;

    return ColoredBox(
      color: BroskieColors.night,
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Text('WORLD 1-$stage',
                style: broskieHeadline(
                    size: 18, color: BroskieColors.amber, letterSpacing: 6)),
            const SizedBox(height: 10),
            Text(info.$1,
                textAlign: TextAlign.center,
                style: broskieHeadline(size: 28, letterSpacing: 4)),
            const SizedBox(height: 6),
            Text(info.$2,
                style: const TextStyle(
                    color: Color(0x99F2E6D4),
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                    fontSize: 11)),
            const SizedBox(height: 28),
            AnimatedBuilder(
              animation: _spin,
              builder: (context, _) => Transform.rotate(
                angle: _spin.value * 2 * pi,
                child: const CustomPaint(
                    size: Size(42, 42), painter: PixelVinylPainter()),
              ),
            ),
            const SizedBox(height: 16),
            Text(_steps[_step],
                style: const TextStyle(
                    color: BroskieColors.amber,
                    fontFamily: 'monospace',
                    letterSpacing: 3,
                    fontSize: 12,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('BROSKIE  ×  ',
                    style: TextStyle(
                        color: BroskieColors.bone,
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.w900)),
                Text('$hearts',
                    style: broskieHeadline(
                        size: 22, color: BroskieColors.cap)),
              ],
            ),
            const Spacer(flex: 3),
            // Fake street in the LOWER THIRD — same silhouette the game uses.
            SizedBox(
              height: 90,
              width: double.infinity,
              child: CustomPaint(painter: _LoadStreetPainter()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiny "BROSKIE × 2" wipe after a fall, SMB lives screen.
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

class _LoadStreetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final street = Paint()..color = const Color(0xFF222533);
    final lip = Paint()..color = BroskieColors.bone;
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.35, size.width, size.height), street);
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.35, size.width, 5), lip);
    // A tiny Broskie blob so the load card teaches the framing.
    final cap = Paint()..color = BroskieColors.cap;
    final bone = Paint()..color = BroskieColors.bone;
    final denim = Paint()..color = const Color(0xFF1F4287);
    final x = size.width * 0.22;
    final y = size.height * 0.35 - 28;
    canvas.drawRect(Rect.fromLTWH(x, y, 18, 10), bone);
    canvas.drawRect(Rect.fromLTWH(x - 2, y - 4, 22, 6), cap);
    canvas.drawRect(Rect.fromLTWH(x + 2, y + 10, 14, 18), denim);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
