import 'package:flutter/material.dart';

class BroskieLoadingScreen extends StatelessWidget {
  const BroskieLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF050711), Color(0xFF171033), Color(0xFF062631)],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 430;
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  right: compact ? 34 : 80,
                  bottom: compact ? -28 : -45,
                  child: Opacity(
                    opacity: 0.72,
                    child: Image.asset(
                      'assets/images/runtime/broskie_player.png',
                      height: constraints.maxHeight * (compact ? 0.9 : 0.82),
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 26 : 64,
                    vertical: compact ? 18 : 42,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.58,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.bolt,
                            color: Color(0xFFFFEC3D),
                            size: 42,
                          ),
                          const FittedBox(
                            child: Text(
                              'BROSKIE',
                              style: TextStyle(
                                color: Color(0xFF47F8FF),
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 7,
                                shadows: [
                                  Shadow(
                                    color: Color(0xAAFF3EC8),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'BOOTING THE REBELLION…',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const LinearProgressIndicator(
                            minHeight: 6,
                            color: Color(0xFFFF3EC8),
                            backgroundColor: Color(0x3347F8FF),
                          ),
                          const SizedBox(height: 9),
                          const Text(
                            'Loading Neo-City, boss systems and illegal levels of individuality.',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BroskieLoadError extends StatelessWidget {
  const BroskieLoadError({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF050711),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF3158),
                  size: 52,
                ),
                const SizedBox(height: 12),
                const Text(
                  'NEO-CITY FAILED TO BOOT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFF3158),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
