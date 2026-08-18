import 'package:flutter/material.dart';
import 'package:broskie_game/game/broskie_game.dart';

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
          color: Colors.black.withOpacity(0.95),
          border: Border.all(color: const Color(0xFF00E5FF), width: 4),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0xFF00E5FF), blurRadius: 15)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "CAMPAIGN STAGE SELECT",
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const Divider(color: Colors.white24, height: 20),

            _buildStageTile(
              stageNum: "1-1",
              title: "The Grey Zone",
              subtitle: "Concrete, Cubes & Intro",
              isUnlocked: true,
              onTap: () {
                game.currentStage.value = 1;
                game.restart();
                game.overlays.remove('LevelSelect');
              },
            ),
            const SizedBox(height: 10),

            _buildStageTile(
              stageNum: "1-2",
              title: "Neon Slums",
              subtitle: "Lasers & Moving Platforms",
              isUnlocked: true,
              onTap: () {
                game.currentStage.value = 2;
                game.restart();
                game.overlays.remove('LevelSelect');
              },
            ),
            const SizedBox(height: 10),

            _buildStageTile(
              stageNum: "1-3",
              title: "Stock Exchange",
              subtitle: "Bull Run & Tower Climb",
              isUnlocked: true,
              onTap: () {
                game.currentStage.value = 3;
                game.restart();
                game.overlays.remove('LevelSelect');
              },
            ),
            const SizedBox(height: 10),

            _buildStageTile(
              stageNum: "1-4",
              title: "Executive Arena",
              subtitle: "The Foreman & Data Broker",
              isUnlocked: true,
              onTap: () {
                game.currentStage.value = 4;
                game.restart();
                game.overlays.remove('LevelSelect');
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () => game.overlays.remove('LevelSelect'),
              child: const Text("CLOSE SELECT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageTile({
    required String stageNum,
    required String title,
    required String subtitle,
    required bool isUnlocked,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isUnlocked ? const Color(0xFF00E5FF) : Colors.grey),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUnlocked ? const Color(0xFF00E5FF) : Colors.grey,
          child: Text(stageNum, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Icon(isUnlocked ? Icons.play_arrow : Icons.lock, color: isUnlocked ? Colors.amber : Colors.grey),
        onTap: isUnlocked ? onTap : null,
      ),
    );
  }
}
