import 'package:flutter/material.dart';

class StageInfo {
  const StageInfo({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.briefing,
    required this.levelWidth,
    required this.skyTop,
    required this.skyBottom,
    required this.accent,
  });

  final int index;
  final String title;
  final String subtitle;
  final String briefing;
  final double levelWidth;
  final Color skyTop;
  final Color skyBottom;
  final Color accent;
}

const stages = <StageInfo>[
  StageInfo(
    index: 0,
    title: 'THE GREY ZONE',
    subtitle: 'Unauthorized Individuality',
    briefing:
        'Break out of orientation, learn the movement line, and reach the hijacked exit.',
    levelWidth: 3000,
    skyTop: Color(0xFF080B1F),
    skyBottom: Color(0xFF241244),
    accent: Color(0xFF47F8FF),
  ),
  StageInfo(
    index: 1,
    title: 'THE FACTORY',
    subtitle: 'Management Is Watching',
    briefing:
        'Cross the production floor and bounce The Foreman out of upper management.',
    levelWidth: 3800,
    skyTop: Color(0xFF160B12),
    skyBottom: Color(0xFF4A1914),
    accent: Color(0xFFFFB329),
  ),
  StageInfo(
    index: 2,
    title: 'NEON SLUMS',
    subtitle: 'Terms and Conditions Apply',
    briefing:
        'The network is hostile. Push through data spikes and weaponized control hacks.',
    levelWidth: 4100,
    skyTop: Color(0xFF090425),
    skyBottom: Color(0xFF3A0750),
    accent: Color(0xFFFF3EC8),
  ),
  StageInfo(
    index: 3,
    title: 'MONOPOLY CORE',
    subtitle: 'Going Live',
    briefing:
        'Climb the core, survive the proxy attacks, and delete the Data Broker for real.',
    levelWidth: 4600,
    skyTop: Color(0xFF020D15),
    skyBottom: Color(0xFF063D47),
    accent: Color(0xFF55FF8A),
  ),
];
