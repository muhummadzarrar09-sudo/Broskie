import 'package:flutter/material.dart';

import '../broskie_game.dart';
import '../models/campaign_progress.dart';
import '../models/stage_catalog.dart';

class MainMenuOverlay extends StatelessWidget {
  const MainMenuOverlay({super.key, required this.game});

  final BroskieGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CampaignProgress>(
      valueListenable: game.campaign,
      builder: (context, progress, _) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xF2050711), Color(0xEE241244)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bolt,
                        color: Color(0xFFFFEC3D),
                        size: 58,
                      ),
                      const FittedBox(
                        child: Text(
                          'BROSKIE',
                          style: TextStyle(
                            color: Color(0xFF47F8FF),
                            fontSize: 78,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 9,
                            shadows: [
                              Shadow(color: Color(0xFFFF3EC8), blurRadius: 20),
                            ],
                          ),
                        ),
                      ),
                      const Text(
                        'BREAK THE STANDARD. FIND YOUR OWN BEAT.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (progress.hasStarted)
                            FilledButton.icon(
                              onPressed: game.gameReady
                                  ? game.continueCampaign
                                  : null,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('CONTINUE'),
                            ),
                          OutlinedButton.icon(
                            onPressed: game.gameReady
                                ? game.startNewCampaign
                                : null,
                            icon: const Icon(Icons.restart_alt),
                            label: Text(
                              progress.hasStarted
                                  ? 'NEW RUN'
                                  : 'START CAMPAIGN',
                            ),
                          ),
                          TextButton.icon(
                            onPressed: game.gameReady
                                ? game.openSettings
                                : null,
                            icon: const Icon(Icons.tune),
                            label: const Text('SETTINGS'),
                          ),
                          TextButton.icon(
                            onPressed: game.openCredits,
                            icon: const Icon(Icons.groups),
                            label: const Text('CREDITS'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'STAGE SELECT',
                        style: TextStyle(
                          color: Color(0xFFFFEC3D),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final stage in stages)
                            _StageButton(
                              stage: stage,
                              unlocked:
                                  game.gameReady &&
                                  stage.index <= progress.highestUnlockedStage,
                              rank: progress.rankFor(stage.index),
                              onPressed: () => game.selectStage(stage.index),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'A compact four-stage campaign • No ads • No fake completed worlds',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StageButton extends StatelessWidget {
  const _StageButton({
    required this.stage,
    required this.unlocked,
    required this.rank,
    required this.onPressed,
  });

  final StageInfo stage;
  final bool unlocked;
  final CampaignRank rank;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 166,
      child: OutlinedButton(
        onPressed: unlocked ? onPressed : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: unlocked ? stage.accent : Colors.white24),
          padding: const EdgeInsets.all(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0${stage.index + 1}'),
                Text(
                  unlocked ? rank.label : '🔒',
                  style: TextStyle(
                    color: stage.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              stage.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
