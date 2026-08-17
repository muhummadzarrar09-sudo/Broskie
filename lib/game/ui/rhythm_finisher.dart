import 'package:flutter/material.dart';

class RhythmFinisherUI extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const RhythmFinisherUI({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "SYNC THE BEAT!",
            style: TextStyle(color: Colors.cyanAccent, fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
          ),
          const SizedBox(height: 20),
          Container(
            width: 300,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.magentaAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "TAP ON THE FLASH!",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
