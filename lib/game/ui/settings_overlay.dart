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
        minimum: const EdgeInsets.all(8),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                color: const Color(0xFF11172A),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: ValueListenableBuilder<CampaignProgress>(
                    valueListenable: game.campaign,
                    builder: (context, progress, _) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FittedBox(
                            child: Text(
                              'SYSTEM SETTINGS',
                              style: TextStyle(
                                color: Color(0xFF47F8FF),
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile.adaptive(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Haptic feedback'),
                            subtitle: const Text('Touch jump and impacts'),
                            value: progress.hapticsEnabled,
                            onChanged: game.setHaptics,
                          ),
                          SwitchListTile.adaptive(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Music & sound effects'),
                            subtitle: const Text('Placeholder neon audio'),
                            value: progress.audioEnabled,
                            onChanged: game.setAudio,
                          ),
                          SwitchListTile.adaptive(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('On-screen controls'),
                            subtitle: const Text(
                              'Hide for keyboard/controller',
                            ),
                            value: progress.showTouchControls,
                            onChanged: game.setTouchControls,
                          ),
                          SwitchListTile.adaptive(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Reduced effects'),
                            subtitle: const Text(
                              'Less glow and visual intensity',
                            ),
                            value: progress.reducedEffects,
                            onChanged: game.setReducedEffects,
                          ),
                          const SizedBox(height: 8),
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
      ),
    );
  }
}
