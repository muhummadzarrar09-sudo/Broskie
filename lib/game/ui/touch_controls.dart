import 'package:broskie_game/game/broskie_game.dart';
import 'package:flutter/material.dart';

class TouchControlsOverlay extends StatelessWidget {
  final BroskieGame game;

  const TouchControlsOverlay({super.key, required this.game});

  Widget _pad({
    required Color border,
    required Widget child,
    required void Function(bool down) onHold,
    double size = 64,
  }) {
    return Listener(
      onPointerDown: (_) => onHold(true),
      onPointerUp: (_) => onHold(false),
      onPointerCancel: (_) => onHold(false),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xE612100C),
          border: Border.all(color: border, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bone = Color(0xFFF2E6D4);
    const volt = Color(0xFFFFB800);
    const cap = Color(0xFFE52521);
    return Stack(
      children: [
        Positioned(
          bottom: 28,
          left: 16,
          child: Row(
            children: [
              _pad(
                border: bone,
                onHold: (down) => game.player.setMove(down ? -1 : 0),
                child: const Icon(Icons.chevron_left, color: bone, size: 36),
              ),
              const SizedBox(width: 12),
              _pad(
                border: bone,
                onHold: (down) => game.player.setMove(down ? 1 : 0),
                child: const Icon(Icons.chevron_right, color: bone, size: 36),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 28,
          right: 16,
          child: Row(
            children: [
              _pad(
                border: const Color(0xFF3DDC84),
                size: 56,
                onHold: (down) {
                  if (down) game.player.tryDash();
                },
                child: const Text('DASH',
                    style: TextStyle(
                        color: Color(0xFF3DDC84),
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 11)),
              ),
              const SizedBox(width: 10),
              _pad(
                border: cap,
                size: 60,
                onHold: (down) {
                  if (down) game.player.throwVinylBoomerang();
                },
                child: const Text('B',
                    style: TextStyle(
                        color: cap,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 22)),
              ),
              const SizedBox(width: 10),
              _pad(
                border: volt,
                size: 72,
                onHold: game.player.setJumpHeld,
                child: const Text('A',
                    style: TextStyle(
                        color: volt,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 26)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
