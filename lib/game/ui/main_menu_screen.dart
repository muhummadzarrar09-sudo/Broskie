import 'dart:async';
import 'dart:math';

import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/difficulty.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flutter/material.dart';

/// Title as the rooftop: menu keyart full-bleed with a slow drift so the
/// city breathes. The headline rides the sky's negative space; the control
/// deck sits in a kit panel over the neon so thumbs never hunt in the rain.
class MainMenuOverlay extends StatefulWidget {
  final BroskieGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _walk;

  @override
  void initState() {
    super.initState();
    _walk =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();
  }

  @override
  void dispose() {
    _walk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return Stack(
      fit: StackFit.expand,
      children: [
        // ROOFTOP: slow Ken Burns drift — the city flexes, not the UI.
        AnimatedBuilder(
          animation: _walk,
          builder: (context, _) {
            final t = sin(_walk.value * 2 * pi);
            return Transform.scale(
              scale: 1.06 + 0.02 * t,
              child: Transform.translate(
                offset: Offset(8 * t, 3 * t),
                child: Image.asset(
                  'assets/images/runtime/menu_keyart.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, _, _) =>
                      const ColoredBox(color: BroskieColors.night),
                ),
              ),
            );
          },
        ),
        // Scrim: guard the sky for the headline, sink the control deck.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x33000000), Colors.transparent, Color(0xB312100C)],
              stops: [0.0, 0.35, 1.0],
            ),
          ),
        ),
        const ScanlineFill(opacity: 0.08),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 14),
                        Text(
                          'BROSKIE',
                          style:
                              broskieHeadline(size: 46, letterSpacing: 10),
                        ),
                        const SizedBox(height: 4),
                        const CustomPaint(
                          size: Size(190, 9),
                          painter: _RooftopBarcodePainter(),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'A KID. A VINYL. A BAD ATTITUDE.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: BroskieColors.amber,
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                            fontSize: 11,
                            shadows: [
                              Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 0,
                                  color: Colors.black)
                            ],
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 400),
                            child: Container(
                              margin:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              padding: const EdgeInsets.all(12),
                              decoration: broskiePanel(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ValueListenableBuilder<BroskieDifficulty>(
                                    valueListenable: game.difficulty,
                                    builder: (context, current, _) => Row(
                                      children:
                                          BroskieDifficulty.values.map((d) {
                                        final on = d == current;
                                        return Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets
                                                .symmetric(horizontal: 4),
                                            child: GestureDetector(
                                              onTap: () {
                                                BroskieAudio.playUiClick();
                                                game.difficulty.value = d;
                                                unawaited(game.savePrefs());
                                              },
                                              child: Container(
                                                height: 38,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: on
                                                      ? BroskieColors.amber
                                                      : const Color(
                                                          0xFF1A1814),
                                                  border: Border.all(
                                                      color:
                                                          BroskieColors.bone,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4),
                                                ),
                                                child: Text(
                                                  d.label,
                                                  style: TextStyle(
                                                    color: on
                                                        ? Colors.black
                                                        : BroskieColors.bone,
                                                    fontFamily: 'monospace',
                                                    fontWeight:
                                                        FontWeight.w900,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ValueListenableBuilder<BroskieDifficulty>(
                                    valueListenable: game.difficulty,
                                    builder: (context, d, _) => Text(
                                      '${d.hearts} HEART${d.hearts == 1 ? '' : 'S'}',
                                      style: const TextStyle(
                                          color: Color(0x99F2E6D4),
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                          letterSpacing: 2),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  ValueListenableBuilder<int>(
                                    valueListenable: game.unlockedStage,
                                    builder: (context, unlocked, _) =>
                                        Column(
                                      children: [
                                        if (unlocked > 1) ...[
                                          _btn(
                                              'CONTINUE  STAGE $unlocked',
                                              BroskieColors.amber,
                                              Colors.black,
                                              () => game
                                                  .startRun(unlocked)),
                                          const SizedBox(height: 10),
                                        ],
                                        _btn(
                                            'NEW RUN',
                                            BroskieColors.bone,
                                            Colors.black,
                                            () => game.startRun(1,
                                                newRun: true)),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _btn(
                                                  'STAGE SELECT',
                                                  const Color(0xFF1A1814),
                                                  BroskieColors.bone,
                                                  game.openLevelSelect),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: _btn(
                                                  'SETTINGS',
                                                  const Color(0xFF1A1814),
                                                  BroskieColors.bone,
                                                  game.openSettings),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _btn(String label, Color bg, Color fg, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: BroskieColors.bone, width: 2),
          ),
        ),
        onPressed: () {
          BroskieAudio.playUiClick();
          onTap();
        },
        child: Text(
          label,
          style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              letterSpacing: 2,
              fontSize: 13),
        ),
      ),
    );
  }
}

/// The villain's signature strip under the headline — bone on sky.
class _RooftopBarcodePainter extends CustomPainter {
  const _RooftopBarcodePainter();

  @override
  void paint(Canvas canvas, Size size) {
    drawBarcode(canvas, Offset.zero & size,
        seed: 404, color: BroskieColors.bone.withValues(alpha: 0.85));
  }

  @override
  bool shouldRepaint(_RooftopBarcodePainter oldDelegate) => false;
}
