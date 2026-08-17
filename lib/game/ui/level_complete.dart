import 'package:flutter/material.dart';

class LevelCompleteOverlay extends StatelessWidget {
  const LevelCompleteOverlay({
    super.key,
    required this.cash,
    required this.enemiesStomped,
    required this.onReplay,
  });

  final int cash;
  final int enemiesStomped;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xD9050711),
      child: SafeArea(
        child: Center(
          child: Semantics(
            namesRoute: true,
            label: 'Level complete',
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF11172A),
                    border: Border.all(
                      color: const Color(0xFFFFC12E),
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Color(0x55FFC12E), blurRadius: 28),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bolt,
                          color: Color(0xFFFFC12E),
                          size: 56,
                        ),
                        const Text(
                          'SYSTEM LIBERATED',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFC12E),
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'BROSKIE COOKED THE MONOPOLY.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _ResultRow(
                          label: 'CASH EXTRACTED',
                          value: '\$$cash',
                          color: const Color(0xFF6CFF83),
                        ),
                        _ResultRow(
                          label: 'OPPS STOMPED',
                          value: '$enemiesStomped',
                          color: const Color(0xFFFF5474),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: onReplay,
                          icon: const Icon(Icons.replay),
                          label: const Text('RUN IT BACK'),
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

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
