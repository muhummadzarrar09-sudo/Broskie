import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flutter/material.dart';

class DialogueBox extends StatelessWidget {
  final String speakerName;
  final String text;
  final VoidCallback onNext;

  const DialogueBox(
      {super.key,
      required this.speakerName,
      required this.text,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(15),
        height: 150,
        decoration: broskiePanel(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              speakerName.toUpperCase(),
              style: const TextStyle(
                color: BroskieColors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Courier',
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: onNext,
                child: const Text(
                  "TAP TO CONTINUE >",
                  style: TextStyle(color: Colors.amber, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
