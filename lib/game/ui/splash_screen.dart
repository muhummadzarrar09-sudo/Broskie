import 'dart:async';
import 'dart:math';

import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

/// Boot load, redesigned: the keyart IS the loader. Broskie mid-air, vinyl
/// away — the art settles out of a push-in as assets land, the city throws
/// chromatic interference frames, and the groove bar on the lip keeps the
/// progress honest. Same jobs, same labels — new body.
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

  /// Broadcast interference: mostly clean signal, hard tears mid-loop.
  static const List<int> _glitchPattern = [0, 0, 1, 0, 0, 2, 0, 0, 1, 0, 0, 0];
  int _glitchTick = 0;
  Timer? _glitchTimer;

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
    _glitchTimer =
        Timer.periodic(const Duration(milliseconds: 160), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _glitchTick++);
    });
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
    _glitchTimer?.cancel();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glitch = _glitchPattern[_glitchTick % _glitchPattern.length];
    // The art settles out of a slight push-in as the bar fills.
    final settle = 1.07 - 0.07 * _progress;

    return Scaffold(
      backgroundColor: BroskieColors.night,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: settle,
            child: Image.asset(
              'assets/images/runtime/splash_keyart.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: BroskieColors.night),
            ),
          ),
          if (glitch > 0) ...[
            // Chromatic tear: the city steals two frames mid-load.
            _GlitchLayer(
              dx: 2.0 * glitch,
              tint: BroskieColors.cyan.withValues(alpha: 0.45),
            ),
            _GlitchLayer(
              dx: -2.0 * glitch,
              tint: BroskieColors.magenta.withValues(alpha: 0.45),
            ),
          ],
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xD912100C)],
                stops: [0.55, 1.0],
              ),
            ),
          ),
          const ScanlineFill(opacity: 0.10),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Column(
                children: [
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BROSKIE',
                              style: broskieHeadline(
                                  size: 20,
                                  color: BroskieColors.amber,
                                  letterSpacing: 6),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _label,
                              style: const TextStyle(
                                  color: BroskieColors.bone,
                                  fontFamily: 'monospace',
                                  letterSpacing: 3,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: const TextStyle(
                            color: Color(0x99F2E6D4),
                            fontFamily: 'monospace',
                            fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _progress > 0 ? _progress : null,
                      minHeight: 6,
                      backgroundColor: const Color(0x882A261C),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          BroskieColors.amber),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One shifted, tinted ghost of the splash art for the glitch frames.
class _GlitchLayer extends StatelessWidget {
  final double dx;
  final Color tint;

  const _GlitchLayer({required this.dx, required this.tint});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(dx, 0),
      child: Image.asset(
        'assets/images/runtime/splash_keyart.png',
        fit: BoxFit.cover,
        filterQuality: FilterQuality.none,
        color: tint,
        colorBlendMode: BlendMode.screen,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
