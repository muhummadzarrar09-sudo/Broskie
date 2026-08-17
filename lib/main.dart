import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game/broskie_game.dart';

void main() {
  runApp(
    const ProviderScope(
      child: BroskieApp(),
    ),
  );
}

class BroskieApp extends ConsumerWidget {
  const BroskieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(
          game: BroskieGame(ref: ref),
          overlayBuilderMap: {
            'HUD': (context, game) => const Center(child: Text('HUD')),
            'GameOver': (context, game) => const Center(child: Text('DELETED')),
          },
          initialActiveOverlays: const ['HUD'],
        ),
      ),
    );
  }
}
