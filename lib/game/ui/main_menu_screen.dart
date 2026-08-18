import 'package:flutter/material.dart';
import 'package:broskie_game/game/broskie_game.dart';

class MainMenuOverlay extends StatelessWidget {
  final BroskieGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Rooftop key art; gradient fallback keeps the menu alive without it.
          Positioned.fill(
            child: Image.asset(
              'assets/images/runtime/menu_keyart.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none, // crisp pixels
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFA0F0C20), Color(0xFA241244)],
                  ),
                ),
              ),
            ),
          ),

          // Readability scrim over the art
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.35), Colors.black.withOpacity(0.62)],
                ),
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "BROSKIE",
                style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  letterSpacing: 8,
                  shadows: [Shadow(color: Colors.black, blurRadius: 24), Shadow(color: Color(0xFF00E5FF), blurRadius: 30)],
                ),
              ),
              const Text(
                "MONOPOLY CORP MUST FALL",
                style: TextStyle(color: Colors.amber, fontSize: 16, fontStyle: FontStyle.italic, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 48),
              ValueListenableBuilder<int>(
                valueListenable: game.unlockedStage,
                builder: (context, unlocked, _) => Column(
                  children: [
                    if (unlocked > 1) ...[
                      _menuButton("CONTINUE — STAGE $unlocked", Colors.amber, Colors.black, () => game.startRun(unlocked)),
                      const SizedBox(height: 14),
                    ],
                    _menuButton("NEW RUN", const Color(0xFF00E5FF), Colors.black, () => game.startRun(1)),
                    const SizedBox(height: 14),
                    _menuButton("STAGE SELECT", Colors.white24, Colors.white, () => game.overlays.add('LevelSelect')),
                    const SizedBox(height: 14),
                    _menuButton("SETTINGS", Colors.white24, Colors.white, () => game.overlays.add('Settings')),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                "CODE + AI ART · BUILT FOR THE CREW",
                style: TextStyle(color: Colors.white24, fontSize: 11, fontFamily: 'monospace', letterSpacing: 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuButton(String label, Color bg, Color fg, VoidCallback onTap) {
    return SizedBox(
      width: 280,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'monospace', letterSpacing: 2),
        ),
      ),
    );
  }
}
