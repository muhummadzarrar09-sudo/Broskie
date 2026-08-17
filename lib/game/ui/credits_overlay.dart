import 'package:flutter/material.dart';

class CreditsOverlay extends StatelessWidget {
  const CreditsOverlay({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xF2050711),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt, color: Color(0xFFFFEC3D), size: 48),
                  const Text(
                    'BROSKIE',
                    style: TextStyle(
                      color: Color(0xFF47F8FF),
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'CREATED BY MUHUMMAD ZARRAR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Built with Flutter + Flame\n\nA personal game about movement, individuality, and refusing the designated path.\n\nConcept boards remain visual references. Runtime art and systems are rendered in code.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(onPressed: onClose, child: const Text('BACK')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
