import 'dart:async';
import 'package:flutter/material.dart';

/// Branded in-app splash: sits between the native launch screen and the
/// main menu while the game boots. Falls back to a gradient if the key
/// art is missing so boot never breaks.
class SplashScreen extends StatefulWidget {
  final Widget next;

  const SplashScreen({super.key, required this.next});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
    _timer = Timer(const Duration(milliseconds: 2600), _goNext);
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
    _timer?.cancel();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C20),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
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
                  builder: (context, _) => Text(
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
                const Text(
                  "MONOPOLY CORP MUST FALL",
                  style: TextStyle(color: Colors.amber, fontSize: 14, fontStyle: FontStyle.italic, fontFamily: 'monospace', letterSpacing: 2),
                ),
                const Spacer(flex: 2),
                const SizedBox(
                  width: 180,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "LOADING NEO-CITY...",
                  style: TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace', letterSpacing: 3),
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
