import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/player.dart';

class PropagandaSign extends SpriteComponent with HasGameRef {
  bool isHacked = false;
  late Sprite welcomeSprite;
  late Sprite obeySprite;

  PropagandaSign({required Vector2 position}) : super(position: position, size: Vector2(64, 32));

  @override
  Future<void> onLoad() async {
    // welcomeSprite = await gameRef.loadSprite('sign_welcome.png');
    // obeySprite = await gameRef.loadSprite('sign_obey.png');
    // sprite = welcomeSprite;
    debugMode = true; // Placeholder for now
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // As player gets closer or reaches a trigger, change the sign
    final player = gameRef.children.whereType<Player>().firstOrNull;
    if (player != null && player.position.x > position.x - 200) {
      if (!isHacked) {
        isHacked = true;
        _switchToObey();
      }
    }
  }

  void _switchToObey() {
    print("Sign Switched: WELCOME -> OBEY");
    // sprite = obeySprite;
  }
}
