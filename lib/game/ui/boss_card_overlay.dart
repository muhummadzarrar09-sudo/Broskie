import 'dart:async';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flutter/material.dart';

/// Fighting-game boss intro card: banner art, name, corporate serial number,
/// barcode stamp. Auto-dismisses — it's cinema, not a roadblock.
class BossCardOverlay extends StatefulWidget {
  final BroskieGame game;

  const BossCardOverlay({super.key, required this.game});

  @override
  State<BossCardOverlay> createState() => _BossCardOverlayState();
}

class _BossCardOverlayState extends State<BossCardOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
        const Duration(milliseconds: 2400), () => widget.game.hideBossCard());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        builder: (context, t, child) => Transform.scale(
            scale: 0.85 + 0.15 * t,
            child: Opacity(opacity: t.clamp(0.0, 1.0), child: child)),
        child: Align(
          alignment: const Alignment(0, -0.35),
          child: Container(
            width: 420,
            decoration: broskiePanel(border: BroskieColors.magenta),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/runtime/${widget.game.bossCardArt}',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (_, _, _) =>
                        Container(color: const Color(0xFF241244)),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: const Color(0xFF0F0C20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      CustomPaint(
                          size: const Size(90, 22),
                          painter: _BarcodeStripPainter()),
                      const Spacer(),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: const Color(0xFF0F0C20),
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.game.bossCardName,
                          style: broskieHeadline(
                              size: 28,
                              color: BroskieColors.amber,
                              letterSpacing: 4)),
                      const SizedBox(height: 2),
                      Text(
                        widget.game.bossCardTitle,
                        style: const TextStyle(
                            color: BroskieColors.bone,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'monospace',
                            letterSpacing: 2),
                      ),
                    ],
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

class _BarcodeStripPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    drawBarcode(canvas, Offset.zero & size,
        seed: 42, color: BroskieColors.bone);
  }

  @override
  bool shouldRepaint(_BarcodeStripPainter oldDelegate) => false;
}
