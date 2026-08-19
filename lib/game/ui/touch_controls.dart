import 'package:broskie_game/game/broskie_game.dart';
import 'package:flutter/material.dart';

class TouchControlsOverlay extends StatelessWidget {
  final BroskieGame game;

  const TouchControlsOverlay({super.key, required this.game});

  Widget _artButton({
    required String asset,
    required double size,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: borderColor, blurRadius: 8)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(asset, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Left D-Pad Controls
        Positioned(
          bottom: 30,
          left: 20,
          child: Row(
            children: [
              GestureDetector(
                onTapDown: (_) => game.player.horizontalDirection = -1,
                onTapUp: (_) => game.player.horizontalDirection = 0,
                onTapCancel: () => game.player.horizontalDirection = 0,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    border:
                        Border.all(color: const Color(0xFF00E5FF), width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Color(0xFF00E5FF), size: 28),
                ),
              ),
              const SizedBox(width: 15),
              GestureDetector(
                onTapDown: (_) => game.player.horizontalDirection = 1,
                onTapUp: (_) => game.player.horizontalDirection = 0,
                onTapCancel: () => game.player.horizontalDirection = 0,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    border:
                        Border.all(color: const Color(0xFF00E5FF), width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_forward_ios,
                      color: Color(0xFF00E5FF), size: 28),
                ),
              ),
            ],
          ),
        ),

        // Right Action Buttons — REAL graffiti art cut from the crew sheet.
        // SPRAY = Volt Dash (the lore sign promised it!), B = Vinyl, A = Jump.
        Positioned(
          bottom: 30,
          right: 20,
          child: Row(
            children: [
              _artButton(
                asset: 'assets/images/runtime/ui_touch_spray.png',
                size: 56,
                borderColor: const Color(0xFF66FF66),
                onTap: () => game.player.tryDash(),
              ),
              const SizedBox(width: 12),
              _artButton(
                asset: 'assets/images/runtime/ui_touch_b.png',
                size: 60,
                borderColor: const Color(0xFFFF3FA4),
                onTap: () => game.player.throwVinylBoomerang(),
              ),
              const SizedBox(width: 12),
              _artButton(
                asset: 'assets/images/runtime/ui_touch_a.png',
                size: 70,
                borderColor: const Color(0xFF00E5FF),
                onTap: () => game.player.requestJump(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
