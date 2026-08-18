import 'dart:async';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

/// Branded in-app splash: sits between the native launch screen and the
/// main menu while REAL work happens — every runtime image is preloaded
/// into Flame's shared cache (instant component onLoads later) and the
/// overlay art into Flutter's cache. The bar shows true load progress.
/// Falls back gracefully: a missing asset is skipped, never fatal.
class SplashScreen extends StatefulWidget {
  final Widget next;

  const SplashScreen({super.key, required this.next});

  /// Everything the game will ask for later, warmed up here.
  static const List<String> flameAssets = [
    'runtime/broskie_walk_sheet.png',
    'runtime/broskie_volt_walk_sheet.png',
    'runtime/broskie_player.png',
    'runtime/corporate_cube.png',
    'runtime/foreman_boss.png',
    'runtime/data_broker_boss.png',
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

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  late final AnimationController _zoom;
  double _progress = 0;
  int _loadedCount = 0;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
    _zoom = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400))..forward();
    _startLoading();
  }

  Future<void> _startLoading() async {
    final minDisplay = Future.delayed(const Duration(milliseconds: 2400));

    // Overlay key art goes into Flutter's image cache.
    final overlayArt = <String>[
      'assets/images/runtime/menu_keyart.png',
      'assets/images/runtime/splash_keyart.png',
    ];
    final total = SplashScreen.flameAssets.length + overlayArt.length;

    void tick() {
      if (!mounted) return;
      setState(() {
        _loadedCount++;
        _progress = _loadedCount / total;
      });
    }

    if (mounted) {
      for (final path in overlayArt) {
        try {
          await precacheImage(AssetImage(path), context);
        } catch (_) {}
        tick();
      }
    }

    // Game art goes into Flame's shared cache — component onLoads become
    // instant cache hits when stages build.
    for (final path in SplashScreen.flameAssets) {
      try {
        await Flame.images.load(path);
      } catch (_) {}
      tick();
    }

    await minDisplay;
    _goNext();
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => widget.next,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _glow.dispose();
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C20),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Slow Ken Burns zoom on the key art
          AnimatedBuilder(
            animation: _zoom,
            builder: (context, child) => Transform.scale(
              scale: 1.0 + 0.08 * _zoom.value,
              child: Transform.translate(
                offset: Offset(-10 * _zoom.value, -6 * _zoom.value),
                child: child,
              ),
            ),
            child: Image.asset(
              'assets/images/runtime/splash_keyart.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none, // keep the pixels crisp
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0F0C20), Color(0xFF241244)],
                  ),
                ),
              ),
            ),
          ),

          // Vignette so the title pops off the art
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.15), Colors.black.withOpacity(0.82)],
                stops: const [0.45, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 4),
                AnimatedBuilder(
                  animation: _glow,
                  builder: (context, _) => Transform.translate(
                    offset: Offset(0, 4 * (1 - _glow.value)),
                    child: Text(
                      "BROSKIE",
                      style: TextStyle(
                        color: const Color(0xFF00E5FF),
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        letterSpacing: 10,
                        shadows: [
                          const Shadow(color: Colors.black, blurRadius: 20),
                          Shadow(color: const Color(0xFF00E5FF), blurRadius: 18 + 26 * _glow.value),
                        ],
                      ),
                    ),
                  ),
                ),
                const Text(
                  "MONOPOLY CORP MUST FALL",
                  style: TextStyle(color: Colors.amber, fontSize: 14, fontStyle: FontStyle.italic, fontFamily: 'monospace', letterSpacing: 2),
                ),
                const Spacer(flex: 2),
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: _progress > 0 ? _progress : null,
                      minHeight: 4,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "LOADING NEO-CITY... ${(_progress * 100).toInt()}%",
                  style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace', letterSpacing: 3),
                ),
                const SizedBox(height: 24),
                const Text(
                  "CODE + AI ART",
                  style: TextStyle(color: Colors.white16, fontSize: 9, fontFamily: 'monospace', letterSpacing: 2),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
