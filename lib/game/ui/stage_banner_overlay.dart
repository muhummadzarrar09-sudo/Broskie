import 'dart:async';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';

/// "STAGE 1-2 — NEON SLUMS" slams on, rides the stage accent, leaves.
class StageBannerOverlay extends StatefulWidget {
  final BroskieGame game;

  const StageBannerOverlay({super.key, required this.game});

  @override
  State<StageBannerOverlay> createState() => _StageBannerOverlayState();
}

class _StageBannerOverlayState extends State<StageBannerOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1700), () => widget.game.hideStageBanner());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.game.currentStage.value;
    final info = BroskieGame.stageInfo[stage] ?? ('UNKNOWN ZONE', 'SIGNAL LOST');
    final accent = Color(BroskieGame.stageAccents[stage] ?? 0xFF00E5FF);

    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 18 * (1 - t)), child: child),
        ),
        child: Align(
          alignment: const Alignment(0, -0.55),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "STAGE 1-$stage",
                style: const TextStyle(color: BroskieColors.amber, fontSize: 13, fontFamily: 'monospace', letterSpacing: 6, shadows: [Shadow(offset: Offset(2, 2), blurRadius: 0, color: Colors.black)]),
              ),
              Text(info.$1, style: broskieHeadline(size: 34, color: accent, letterSpacing: 6)),
              Text(
                info.$2,
                style: const TextStyle(color: BroskieColors.bone, fontSize: 11, fontStyle: FontStyle.italic, fontFamily: 'monospace', letterSpacing: 3, shadows: [Shadow(offset: Offset(1, 1), blurRadius: 0, color: Colors.black)]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
