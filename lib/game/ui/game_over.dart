import 'package:flutter/material.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.onRestart,
    required this.onMenu,
  });

  final VoidCallback onRestart;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xD9050711),
      child: SafeArea(
        child: Center(
          child: Semantics(
            namesRoute: true,
            label: 'Game over. Broskie was deleted.',
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: -0.06,
                    child: FittedBox(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFFF3158),
                            width: 7,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'DELETED',
                          style: TextStyle(
                            color: Color(0xFFFF3158),
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'HELL NA. WE GOING BACK IN.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onRestart,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('REBOOT STAGE'),
                  ),
                  TextButton(
                    onPressed: onMenu,
                    child: const Text('RETURN TO MENU'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
