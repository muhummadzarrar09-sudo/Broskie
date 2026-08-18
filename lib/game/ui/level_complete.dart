import 'package:flutter/material.dart';

import '../models/campaign_progress.dart';
import '../models/game_hud_state.dart';

class LevelCompleteOverlay extends StatelessWidget {
  const LevelCompleteOverlay({
    super.key,
    required this.result,
    required this.finalStage,
    required this.onNext,
    required this.onReplay,
    required this.onMenu,
  });

  final StageResult result;
  final bool finalStage;
  final VoidCallback onNext;
  final VoidCallback onReplay;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xD9050711),
      child: SafeArea(
        child: Center(
          child: Semantics(
            namesRoute: true,
            label: 'Stage complete with rank ${result.rank.label}',
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
                        Text(
                          result.rank.label,
                          style: const TextStyle(
                            color: Color(0xFFFFEC3D),
                            fontSize: 68,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'STAGE LIBERATED',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFC12E),
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _ResultRow(
                          label: 'CASH EXTRACTED',
                          value: '\$${result.cash}',
                          color: const Color(0xFF6CFF83),
                        ),
                        _ResultRow(
                          label: 'OPPS STOMPED',
                          value: '${result.enemiesDefeated}',
                          color: const Color(0xFFFF5474),
                        ),
                        _ResultRow(
                          label: 'RUN TIME',
                          value: _clock(result.elapsedSeconds),
                          color: const Color(0xFF47F8FF),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: onNext,
                          icon: Icon(
                            finalStage ? Icons.flag : Icons.arrow_forward,
                          ),
                          label: Text(
                            finalStage ? 'FINISH THE STORY' : 'NEXT STAGE',
                          ),
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            TextButton(
                              onPressed: onReplay,
                              child: const Text('REPLAY'),
                            ),
                            TextButton(
                              onPressed: onMenu,
                              child: const Text('MENU'),
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

  String _clock(int seconds) {
    final minutes = seconds ~/ 60;
    return '$minutes:${(seconds % 60).toString().padLeft(2, '0')}';
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
