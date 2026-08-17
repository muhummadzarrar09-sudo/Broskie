import 'package:flutter/material.dart';

import '../broskie_game.dart';
import '../models/campaign_progress.dart';

class SettingsOverlay extends StatelessWidget {
  const SettingsOverlay({super.key, required this.game});

  final BroskieGame game;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xE8050711),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              color: const Color(0xFF11172A),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ValueListenableBuilder<CampaignProgress>(
                  valueListenable: game.campaign,
                  builder: (context, progress, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'SYSTEM SETTINGS',
                          style: TextStyle(
                            color: Color(0xFF47F8FF),
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SwitchListTile(
                          title: const Text('Haptic feedback'),
                          subtitle: const Text(
                            'Touch jump and impact feedback',
                          ),
                          value: progress.hapticsEnabled,
                          onChanged: game.setHaptics,
                        ),
                        SwitchListTile(
                          title: const Text('On-screen controls'),
                          subtitle: const Text(
                            'Hide when using keyboard or controller',
                          ),
                          value: progress.showTouchControls,
                          onChanged: game.setTouchControls,
                        ),
                        SwitchListTile(
                          title: const Text('Reduced effects'),
                          subtitle: const Text(
                            'Lower glow and background motion intensity',
                          ),
                          value: progress.reducedEffects,
                          onChanged: game.setReducedEffects,
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: game.closeSettings,
                          icon: const Icon(Icons.check),
                          label: const Text('SAVE & CLOSE'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
