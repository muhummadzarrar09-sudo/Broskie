import 'package:flutter/material.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onSettings,
    required this.onMenu,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onSettings;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xCC050711),
      child: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Center(
          child: SingleChildScrollView(
            child: Semantics(
              namesRoute: true,
              label: 'Game paused',
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  color: const Color(0xFF11172A),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFF47F8FF), width: 3),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FittedBox(
                          child: Text(
                            'SYSTEM PAUSED',
                            style: TextStyle(
                              color: Color(0xFF47F8FF),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            FilledButton.icon(
                              onPressed: onResume,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('RESUME'),
                            ),
                            TextButton.icon(
                              onPressed: onRestart,
                              icon: const Icon(Icons.restart_alt),
                              label: const Text('RESTART'),
                            ),
                            TextButton.icon(
                              onPressed: onSettings,
                              icon: const Icon(Icons.tune),
                              label: const Text('SETTINGS'),
                            ),
                            TextButton.icon(
                              onPressed: onMenu,
                              icon: const Icon(Icons.home),
                              label: const Text('MENU'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
