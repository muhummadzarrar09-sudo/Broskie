import 'package:flutter/material.dart';

class LevelCompleteOverlay extends StatelessWidget {
  final int coins;
  final int enemiesStomped;
  final VoidCallback onNextLevel;

  const LevelCompleteOverlay({
    super.key,
    required this.coins,
    required this.enemiesStomped,
    required this.onNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          border: Border.all(color: Colors.amber, width: 4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "LEVEL CLEARED!",
              style: TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
            ),
            const SizedBox(height: 10),
            const Text(
              "HELL NAAAAA, BROSKIE COOKED!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const Divider(color: Colors.white24),
            Text("CASH: \$$coins", style: const TextStyle(color: Colors.greenAccent, fontSize: 18)),
            Text("CUBES STOMPED: $enemiesStomped", style: const TextStyle(color: Colors.redAccent, fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: onNextLevel,
              child: const Text("NEXT LEVEL", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
