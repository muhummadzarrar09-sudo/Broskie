import 'package:flutter/material.dart';

import '../broskie_game.dart';
import '../models/game_hud_state.dart';

class BroskieHud extends StatelessWidget {
  const BroskieHud({super.key, required this.game});

  final BroskieGame game;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final compact = screen.width < 760 || screen.height < 430;
    return ValueListenableBuilder<GameHudState>(
      valueListenable: game.hud,
      builder: (context, state, _) {
        return SafeArea(
          minimum: EdgeInsets.symmetric(
            horizontal: compact ? 6 : 12,
            vertical: compact ? 4 : 10,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: _StatusBar(
                  state: state,
                  compact: compact,
                  onPause: game.togglePause,
                ),
              ),
              if (state.broadcast != null)
                Positioned(
                  top: compact
                      ? (state.bossActive ? 105 : 82)
                      : (state.bossActive ? 126 : 106),
                  left: compact ? 12 : 90,
                  right: compact ? 12 : 90,
                  child: IgnorePointer(
                    child: Semantics(
                      liveRegion: true,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xDD11172A),
                          border: Border.all(color: const Color(0xFFFF3EC8)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            state.broadcast!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFFF36A),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (state.phase == GamePhase.playing && game.showTouchControls)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _TouchControls(game: game, compact: compact),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.state,
    required this.compact,
    required this.onPause,
  });

  final GameHudState state;
  final bool compact;
  final VoidCallback onPause;

  String _clock(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _HudChip(
                compact: compact,
                semanticLabel: '${state.health} health remaining',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        index < state.health
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: const Color(0xFFFF3D67),
                        size: compact ? 17 : 22,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: compact ? 4 : 8),
              _HudChip(
                compact: compact,
                semanticLabel: '${state.cash} cash',
                child: Text(
                  compact ? '\$${state.cash}' : 'CASH  \$${state.cash}',
                  style: const TextStyle(
                    color: Color(0xFF6CFF83),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              SizedBox(width: compact ? 4 : 8),
              _HudChip(
                compact: compact,
                semanticLabel:
                    'Stage ${state.stageNumber}, ${state.stageTitle}, ${state.elapsedSeconds} seconds',
                child: Text(
                  compact
                      ? '${state.stageNumber}/4  ${_clock(state.elapsedSeconds)}'
                      : '${state.stageNumber}/4  ${state.stageTitle}  ${_clock(state.elapsedSeconds)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              if (state.powered) ...[
                SizedBox(width: compact ? 4 : 8),
                _HudChip(
                  compact: compact,
                  semanticLabel: 'Volt Cola active',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bolt,
                        color: Color(0xFFFFEC3D),
                        size: 20,
                      ),
                      if (!compact)
                        const Text(
                          'VOLT MODE',
                          style: TextStyle(
                            color: Color(0xFF4AF8FF),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              IconButton.filledTonal(
                tooltip: 'Pause game',
                onPressed: onPause,
                icon: Icon(Icons.pause, size: compact ? 18 : 24),
                constraints: BoxConstraints.tightFor(
                  width: compact ? 38 : 48,
                  height: compact ? 38 : 48,
                ),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  foregroundColor: const Color(0xFF47F8FF),
                  backgroundColor: const Color(0xCC11172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: state.progress,
              color: const Color(0xFF47F8FF),
              backgroundColor: const Color(0xAA11172A),
              semanticsLabel: 'Level progress',
              semanticsValue: '${(state.progress * 100).round()}',
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              SizedBox(
                width: compact ? 58 : 108,
                child: Text(
                  compact
                      ? '${state.flow.round()}%'
                      : 'FLOW: ${state.flowLabel}',
                  style: const TextStyle(
                    color: Color(0xFFFFEC3D),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  minHeight: 5,
                  value: state.flow / 100,
                  color: const Color(0xFFFFEC3D),
                  backgroundColor: const Color(0x6611172A),
                  semanticsLabel: 'Flow meter, ${state.flowLabel}',
                  semanticsValue: '${state.flow.round()}',
                ),
              ),
              if (state.controlsInverted)
                Padding(
                  padding: EdgeInsets.only(left: compact ? 6 : 12),
                  child: Text(
                    compact ? '⚠ HACKED' : '⚠ CONTROLS HACKED',
                    style: const TextStyle(
                      color: Color(0xFFFF3EC8),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          if (state.bossActive) ...[
            const SizedBox(height: 9),
            Semantics(
              label:
                  '${state.stageNumber == 4 ? 'Data Broker' : 'The Foreman'} boss health ${state.bossHealth} of ${state.bossMaxHealth}',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.stageNumber == 4 ? 'DATA BROKER' : 'THE FOREMAN',
                    style: TextStyle(
                      fontSize: compact ? 11 : 14,
                      color: state.stageNumber == 4
                          ? const Color(0xFF55FF8A)
                          : const Color(0xFFFFB329),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(width: compact ? 7 : 12),
                  SizedBox(
                    width: compact ? 145 : 220,
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: state.bossHealth / state.bossMaxHealth,
                      color: const Color(0xFFFF3D58),
                      backgroundColor: const Color(0xAA11172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({
    required this.semanticLabel,
    required this.child,
    this.compact = false,
  });

  final String semanticLabel;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xCC11172A),
          border: Border.all(color: const Color(0x6647F8FF)),
          borderRadius: BorderRadius.circular(compact ? 9 : 12),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 7 : 12,
            vertical: compact ? 5 : 8,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TouchControls extends StatelessWidget {
  const _TouchControls({required this.game, required this.compact});

  final BroskieGame game;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scale = game.controlScale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _HoldButton(
          size: (compact ? 68 : 84) * scale,
          label: 'Move left',
          icon: Icons.arrow_left_rounded,
          onChanged: game.setTouchLeft,
        ),
        SizedBox(width: compact ? 9 : 14),
        _HoldButton(
          size: (compact ? 68 : 84) * scale,
          label: 'Move right',
          icon: Icons.arrow_right_rounded,
          onChanged: game.setTouchRight,
        ),
        const Spacer(),
        _HoldButton(
          size: (compact ? 66 : 78) * scale,
          label: 'Dash',
          icon: Icons.double_arrow_rounded,
          accent: const Color(0xFFFFEC3D),
          onChanged: (pressed) {
            if (pressed) {
              game.dash();
            }
          },
        ),
        SizedBox(width: compact ? 9 : 14),
        _HoldButton(
          size: (compact ? 74 : 88) * scale,
          label: 'Jump',
          icon: Icons.arrow_upward_rounded,
          accent: const Color(0xFFFF3EC8),
          onChanged: (pressed) {
            if (pressed) {
              game.jump();
            }
          },
        ),
      ],
    );
  }
}

class _HoldButton extends StatefulWidget {
  const _HoldButton({
    required this.label,
    required this.icon,
    required this.onChanged,
    this.size = 74,
    this.accent = const Color(0xFF47F8FF),
  });

  final double size;
  final String label;
  final IconData icon;
  final ValueChanged<bool> onChanged;
  final Color accent;

  @override
  State<_HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<_HoldButton> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed == pressed) {
      return;
    }
    _pressed = pressed;
    widget.onChanged(pressed);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (_pressed) {
      widget.onChanged(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: Listener(
        onPointerDown: (_) => _setPressed(true),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _pressed
                ? widget.accent.withValues(alpha: 0.42)
                : const Color(0x9911172A),
            border: Border.all(color: widget.accent, width: _pressed ? 4 : 2),
            borderRadius: BorderRadius.circular(widget.size * 0.27),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: widget.accent.withValues(alpha: 0.5),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            widget.icon,
            color: widget.accent,
            size: widget.size * 0.62,
          ),
        ),
      ),
    );
  }
}
