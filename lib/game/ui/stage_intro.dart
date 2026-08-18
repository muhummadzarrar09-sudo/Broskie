import 'package:flutter/material.dart';

import '../broskie_game.dart';

class StageIntroOverlay extends StatelessWidget {
  const StageIntroOverlay({super.key, required this.game});

  final BroskieGame game;

  @override
  Widget build(BuildContext context) {
    final stage = game.currentStage;
    return ColoredBox(
      color: const Color(0xD9050711),
      child: SafeArea(
        child: Center(
          child: Semantics(
            namesRoute: true,
            label: 'Stage ${stage.index + 1}: ${stage.title}',
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'STAGE 0${stage.index + 1}',
                      style: TextStyle(
                        color: stage.accent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      child: Text(
                        stage.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      stage.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: stage.accent,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      stage.briefing,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 17,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 26),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: stage.accent,
                        foregroundColor: const Color(0xFF08101B),
                      ),
                      onPressed: game.beginStage,
                      icon: const Icon(Icons.directions_run),
                      label: const Text(
                        'DROP IN',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    TextButton(
                      onPressed: game.showMenu,
                      child: const Text('BACK TO MENU'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
