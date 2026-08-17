import 'dart:typed_data';
import 'package:flame/components.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/enemy_factory.dart';
import 'package:broskie_game/game/blocks/interactable_block.dart';

class BinaryLevelLoader {
  static const int TYPE_FLOOR = 1;
  static const int TYPE_ENEMY = 2;
  static const int TYPE_BLOCK = 3;

  // Optimized Binary Spawner
  static void loadFromBytes(BroskieGame game, Uint8List data) {
    final bd = ByteData.view(data.buffer);
    int offset = 0;

    while (offset < bd.lengthInBytes) {
      final type = bd.getUint8(offset++);
      final x = bd.getFloat32(offset); offset += 4;
      final y = bd.getFloat32(offset); offset += 4;

      if (type == TYPE_FLOOR) {
        final sx = bd.getFloat32(offset); offset += 4;
        final sy = bd.getFloat32(offset); offset += 4;
        game.add(Floor(Vector2(x, y), Vector2(sx, sy)));
      } else if (type == TYPE_ENEMY) {
        // Assume type 0 = cube for now
        game.add(EnemyFactory.spawn('cube', Vector2(x, y)));
      } else if (type == TYPE_BLOCK) {
        // Assume type 0 = mystery
        game.add(InteractableBlock(position: Vector2(x, y), type: BlockType.mystery));
      }
    }
  }
}
