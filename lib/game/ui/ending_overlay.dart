import 'package:flutter/material.dart';

import '../broskie_game.dart';
import '../models/campaign_progress.dart';
import '../models/stage_catalog.dart';

class EndingOverlay extends StatelessWidget {
  const EndingOverlay({super.key, required this.game});

  final BroskieGame game;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xF5050711),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt, color: Color(0xFFFFEC3D), size: 62),
                  const Text(
                    'SYSTEM LIBERATED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF55FF8A),
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'The Data Broker is gone. The city waits for another set of instructions. Broskie refuses to write them.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '“Standardization is over. Everyone, find your own beat.”',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF47F8FF),
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ValueListenableBuilder<CampaignProgress>(
                    valueListenable: game.campaign,
                    builder: (context, progress, _) {
                      return Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        children: [
                          for (final stage in stages)
                            Chip(
                              avatar: CircleAvatar(
                                backgroundColor: stage.accent,
                                child: Text('${stage.index + 1}'),
                              ),
                              label: Text(
                                '${stage.title}: ${progress.rankFor(stage.index).label}',
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: game.showMenu,
                    icon: const Icon(Icons.home),
                    label: const Text('RETURN TO NEO-CITY'),
                  ),
                  TextButton(
                    onPressed: game.openCredits,
                    child: const Text('VIEW CREDITS'),
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
