import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flutter/material.dart';

class LevelSelectOverlay extends StatelessWidget {
  final BroskieGame game;

  const LevelSelectOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.95),
          border: Border.all(color: const Color(0xFF00E5FF), width: 4),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0xFF00E5FF), blurRadius: 15)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("CAMPAIGN STAGE SELECT", style: broskieHeadline(size: 20)),
            const Divider(color: Colors.white24, height: 20),
            ValueListenableBuilder<int>(
              valueListenable: game.unlockedStage,
              builder: (context, unlocked, _) => Column(
                children: [
                  _buildStageTile(
                    stageNum: "1-1",
                    title: "The Grey Zone",
                    subtitle: "Concrete, Cubes & Intro",
                    isUnlocked: unlocked >= 1,
                    stage: 1,
                    onTap: () => _launch(1),
                  ),
                  const SizedBox(height: 10),
                  _buildStageTile(
                    stageNum: "1-2",
                    title: "Neon Slums",
                    subtitle: "Lasers & Moving Platforms",
                    isUnlocked: unlocked >= 2,
                    stage: 2,
                    onTap: () => _launch(2),
                  ),
                  const SizedBox(height: 10),
                  _buildStageTile(
                    stageNum: "1-3",
                    title: "Stock Exchange",
                    subtitle: "Bull Run & Tower Climb",
                    isUnlocked: unlocked >= 3,
                    stage: 3,
                    onTap: () => _launch(3),
                  ),
                  const SizedBox(height: 10),
                  _buildStageTile(
                    stageNum: "1-4",
                    title: "Executive Arena",
                    subtitle: "The Foreman & Data Broker",
                    isUnlocked: unlocked >= 4,
                    stage: 4,
                    onTap: () => _launch(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                BroskieAudio.playUiClick();
                game.overlays.remove('LevelSelect');
              },
              child: const Text("CLOSE SELECT",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _launch(int stage) {
    BroskieAudio.playUiClick();
    game.currentStage.value = stage;
    game.restart();
    game.overlays.remove('LevelSelect');
    game.overlays.remove('MainMenu');
  }

  Widget _buildStageTile({
    required String stageNum,
    required String title,
    required String subtitle,
    required bool isUnlocked,
    required int stage,
    required VoidCallback onTap,
  }) {
    final best = game.bestRankLabelFor(stage);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isUnlocked ? const Color(0xFF00E5FF) : Colors.grey),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUnlocked ? const Color(0xFF00E5FF) : Colors.grey,
          child: Text(stageNum,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUnlocked && best != '—')
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  best,
                  style: TextStyle(
                    color: best == 'S'
                        ? Colors.amber
                        : (best == 'A' ? Colors.cyanAccent : Colors.white54),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            Icon(isUnlocked ? Icons.play_arrow : Icons.lock,
                color: isUnlocked ? Colors.amber : Colors.grey),
          ],
        ),
        onTap: isUnlocked ? onTap : null,
      ),
    );
  }
}
