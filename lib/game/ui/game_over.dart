import 'package:flutter/material.dart';

class GameOverOverlay extends StatelessWidget {
  final VoidCallback onRestart;

  const GameOverOverlay({super.key, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The "DELETED" Stamp
          Transform.rotate(
            angle: -0.2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "DELETED",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Impact',
                ),
              ),
            ),
          ),
          
          // The Broskie Call to Action
          Positioned(
            bottom: 100,
            child: Column(
              children: [
                const Text(
                  "HELL NA, WE GOING BACK IN!",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Icon(Icons.arrow_downward, color: Colors.amber, size: 50), // Pointing to restart
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: onRestart,
                  child: const Text("REBOOT SYSTEM", style: TextStyle(color: Colors.black, fontSize: 22)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
