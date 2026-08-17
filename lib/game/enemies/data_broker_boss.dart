import 'dart:math';
import 'package:flame/components.dart';
import 'package:broskie_game/game/player.dart';
import 'package:broskie_game/game/broskie_game.dart';

class DataBrokerBoss extends SpriteAnimationComponent with HasGameRef<BroskieGame> {
  int health = 8;
  double attackTimer = 0;
  final Random _rng = Random();

  DataBrokerBoss({required Vector2 position}) : super(position: position, size: Vector2(160, 120));

  @override
  void update(double dt) {
    super.update(dt);
    attackTimer += dt;

    if (attackTimer > 4.0) {
      attackTimer = 0;
      _triggerRandomAttack();
    }
  }

  void _triggerRandomAttack() {
    int attackType = _rng.nextInt(4);

    switch (attackType) {
      case 0:
        _laserWeb();
        break;
      case 1:
        _controlHack();
        break;
      case 2:
        _spawnGlitchClones();
        break;
      case 3:
        _randomHiddenFeature();
        break;
    }
  }

  void _laserWeb() {
    print("Data-Broker: 'Spider in the web...' (Laser Web Activated)");
  }

  void _controlHack() {
    print("Data-Broker: 'Hacking your neural link!' (Controls Inverted)");
    final player = gameRef.children.whereType<Player>().firstOrNull;
    if (player != null) {
      player.controlsInverted = true;
      player.hackTimer = 5.0;
    }
  }

  void _spawnGlitchClones() {
    print("Data-Broker: 'I have your data. I have YOU.' (Clones Spawned)");
  }

  void _randomHiddenFeature() {
    print("RANDOM GLITCH ACTIVATED!");
  }

  bool isFake = true;

  void hit() {
    health--;
    if (isFake && health <= 4) {
      _triggerFakeOut();
    }
    if (health <= 0) {
      removeFromParent();
    }
  }

  void _triggerFakeOut() {
    isFake = false;
    health = 8;
    print("Data-Broker: 'That was just a proxy, Broskie...'");
    print("Data-Broker: 'NOW WE GOING LIVE!'");
  }
}
