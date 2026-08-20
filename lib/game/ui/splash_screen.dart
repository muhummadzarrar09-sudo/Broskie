import 'dart:async';
import 'dart:math';

import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

/// Boot load: labeled jobs, spinning vinyl, street in the lower third.
/// Same silhouette the in-game camera will use — teaching the frame.
class SplashScreen extends StatefulWidget {
  final Widget next;

  const SplashScreen({super.key, required this.next});

  static const List<String> flameAssets = [
    'runtime/broskie_walk_sheet.png',
    'runtime/broskie_volt_walk_sheet.png',
    'runtime/corporate_cube.png',
    'runtime/foreman_boss.png',
    'runtime/data_broker_boss.png',
    'runtime/bulldozer_drone.png',
    'runtime/audit_drone.png',
    'runtime/hater_drone.png',
    'runtime/grey_zone_background.png',
    'runtime/neon_slums_background.png',
    'runtime/factory_background.png',
    'runtime/monopoly_core_background.png',
    'skyline_far.png',
    'skyline_near.png',
  ];

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  double _progress = 0;
  int _loadedCount = 0;
  String _label = 'WAKE UP';

  static const _labels = [
    'PRESSING THE VINYL',
    'CUTTING SPRITES',
    'PAVING GREY ZONE',
    'PAVING SLUMS',
    'PAVING THE EXCHANGE',
    'PAVING THE ARENA',
    'CUEING CHIPMUNKS',
  ];

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    _startLoading();
  }

  Future<void> _startLoading() async {
    final minDisplay = Future<void>.delayed(const Duration(milliseconds: 1800));
    final overlayArt = <String>[
      'assets/images/runtime/menu_keyart.png',
      'assets/images/runtime/splash_keyart.png',
      'assets/images/runtime/foreman_intro.png',
      'assets/images/runtime/broker_intro.png',
    ];
    final total = SplashScreen.flameAssets.length + overlayArt.length;

    void tick(String label) {
      if (!mounted) return;
      setState(() {
        _loadedCount++;
        _progress = _loadedCount / total;
        _label = label;
      });
    }

    if (mounted) {
      for (final path in overlayArt) {
        try {
          await precacheImage(AssetImage(path), context);
        } catch (_) {}
        tick(_labels[0]);
      }
    }

    for (var i = 0; i < SplashScreen.flameAssets.length; i++) {
      try {
        await Flame.images.load(SplashScreen.flameAssets[i]);
      } catch (_) {}
      tick(_labels[min(1 + i ~/ 3, _labels.length - 1)]);
    }

    await minDisplay;
    _goNext();
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => widget.next,
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BroskieColors.night,
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  Text('BROSKIE',
                      style: broskieHeadline(size: 52, letterSpacing: 8)),
                  const SizedBox(height: 8),
                  const Text(
                    'A KID. A VINYL. A BAD ATTITUDE.',
                    style: TextStyle(
                        color: BroskieColors.amber,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                        fontSize: 11),
                  ),
                  const SizedBox(height: 28),
                  AnimatedBuilder(
                    animation: _spin,
                    builder: (context, _) => Transform.rotate(
                      angle: _spin.value * 2 * pi,
                      child: const CustomPaint(
                          size: Size(36, 36), painter: PixelVinylPainter()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(_label,
                      style: const TextStyle(
                          color: BroskieColors.bone,
                          fontFamily: 'monospace',
                          letterSpacing: 3,
                          fontSize: 12,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _progress > 0 ? _progress : null,
                        minHeight: 6,
                        backgroundColor: const Color(0xFF2A261C),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            BroskieColors.amber),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${(_progress * 100).toInt()}%',
                      style: const TextStyle(
                          color: Color(0x66F2E6D4),
                          fontFamily: 'monospace',
                          fontSize: 11)),
                  const Spacer(),
                ],
              ),
            ),
          ),
          // LOWER THIRD = the street. Same idea as the in-game camera.
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(painter: _SplashStreetPainter(_progress)),
          ),
        ],
      ),
    );
  }
}

class _SplashStreetPainter extends CustomPainter {
  final double progress;

  _SplashStreetPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF222533));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 6),
        Paint()..color = BroskieColors.bone);
    // Broskie walks along the lip as the bar fills — lower-middle framing.
    final x = 24 + (size.width - 64) * progress.clamp(0.0, 1.0);
    const y = 18.0;
    canvas.drawRect(
        Rect.fromLTWH(x, y, 20, 12), Paint()..color = BroskieColors.bone);
    canvas.drawRect(
        Rect.fromLTWH(x - 2, y - 5, 24, 7), Paint()..color = BroskieColors.cap);
    canvas.drawRect(Rect.fromLTWH(x + 2, y + 12, 16, 22),
        Paint()..color = const Color(0xFF1F4287));
  }

  @override
  bool shouldRepaint(_SplashStreetPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
