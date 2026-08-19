import 'package:broskie_game/game/broskie_game.dart';
import 'package:flutter/material.dart';

class TouchControlsOverlay extends StatelessWidget {
  final BroskieGame game;

  const TouchControlsOverlay({super.key, required this.game});

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
                    border: Border.all(color: const Color(0xFF00E5FF), width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF00E5FF), size: 28),
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
                    border: Border.all(color: const Color(0xFF00E5FF), width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_forward_ios, color: Color(0xFF00E5FF), size: 28),
                ),
              ),
            ],
          ),
        ),

        // Right Action Buttons (Graffiti Style A, B, SPRAY)
        Positioned(
          bottom: 30,
          right: 20,
          child: Row(
            children: [
              // Attack / Boomerang (B)
              GestureDetector(
                onTap: () => game.player.throwVinylBoomerang(),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [BoxShadow(color: Colors.pink, blurRadius: 8)],
                  ),
                  child: const Center(
                    child: Text("B", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ),
                ),
              ),
              const SizedBox(width: 15),

              // Jump (A)
              GestureDetector(
                onTap: () => game.player.requestJump(),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [BoxShadow(color: Colors.amber, blurRadius: 10)],
                  ),
                  child: const Center(
                    child: Text("A", style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
