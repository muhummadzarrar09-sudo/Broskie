import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../broskie_game.dart';
import '../models/game_hud_state.dart';

class BroskieHud extends StatelessWidget {
  const BroskieHud({super.key, required this.game});

  final BroskieGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GameHudState>(
      valueListenable: game.hud,
      builder: (context, state, _) {
        return SafeArea(
          minimum: const EdgeInsets.all(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: _StatusBar(state: state, onPause: game.togglePause),
              ),
              if (state.phase == GamePhase.playing)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _TouchControls(game: game),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.state, required this.onPause});

  final GameHudState state;
  final VoidCallback onPause;

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
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _HudChip(
                semanticLabel: '${state.cash} cash',
                child: Text(
                  'CASH  \$${state.cash}',
                  style: const TextStyle(
                    color: Color(0xFF6CFF83),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (state.powered) ...[
                const SizedBox(width: 8),
                const _HudChip(
                  semanticLabel: 'Volt Cola active',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, color: Color(0xFFFFEC3D), size: 20),
                      Text(
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
                icon: const Icon(Icons.pause),
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
              semanticsValue: '${(state.progress * 100).round()} percent',
            ),
          ),
          if (state.bossActive) ...[
            const SizedBox(height: 9),
            Semantics(
              label:
                  'The Foreman boss health ${state.bossHealth} of ${state.bossMaxHealth}',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'THE FOREMAN',
                    style: TextStyle(
                      color: Color(0xFFFFB329),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 220,
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
  const _HudChip({required this.semanticLabel, required this.child});

  final String semanticLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xCC11172A),
          border: Border.all(color: const Color(0x6647F8FF)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: child,
        ),
      ),
    );
  }
}

class _TouchControls extends StatelessWidget {
  const _TouchControls({required this.game});

  final BroskieGame game;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _HoldButton(
          label: 'Move left',
          icon: Icons.arrow_left_rounded,
          onChanged: game.setTouchLeft,
        ),
        const SizedBox(width: 12),
        _HoldButton(
          label: 'Move right',
          icon: Icons.arrow_right_rounded,
          onChanged: game.setTouchRight,
        ),
        const Spacer(),
        _HoldButton(
          label: 'Jump',
          icon: Icons.arrow_upward_rounded,
          accent: const Color(0xFFFF3EC8),
          onChanged: (pressed) {
            if (pressed) {
              HapticFeedback.lightImpact();
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
    this.accent = const Color(0xFF47F8FF),
  });

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
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: _pressed
                ? widget.accent.withValues(alpha: 0.42)
                : const Color(0x9911172A),
            border: Border.all(color: widget.accent, width: _pressed ? 4 : 2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: widget.accent.withValues(alpha: 0.5),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Icon(widget.icon, color: widget.accent, size: 46),
        ),
      ),
    );
  }
}
