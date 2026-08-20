import 'dart:ui' as ui;

import 'package:broskie_game/game/broskie_game.dart';
import 'package:flame/components.dart';

/// AI-art stage backdrop, tiled horizontally at native aspect ratio and
/// bottom-aligned with the street line. Renders behind all gameplay
/// (priority -50); the sky parallax sits further back at -100.
///
/// If the image fails to load the component renders nothing and the
/// parallax sky remains visible, so stages always have a background.
class StageBackdrop extends PositionComponent
    with HasGameReference<BroskieGame> {
  static const double tileHeight = 700;
  static const double groundBottom = 600;

  final String imagePath;
  final double levelWidth;
  ui.Image? _image;

  StageBackdrop({required this.imagePath, required this.levelWidth})
      : super(
          position: Vector2(-160, groundBottom - tileHeight),
          size: Vector2(levelWidth + 320, tileHeight),
          priority: -50,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      _image = await game.images.load(imagePath);
    } catch (_) {
      // Missing art falls back to the sky parallax automatically.
    }
  }

  @override
  void render(ui.Canvas canvas) {
    final img = _image;
    if (img == null) return;
    final tileWidth = img.width * (tileHeight / img.height);
    final src =
        ui.Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.low;
    // Alternate tiles mirror so seams meet their own reflection instead of a
    // hard cut in the AI art.
    var flip = false;
    for (double x = 0; x < size.x; x += tileWidth) {
      if (flip) {
        canvas.save();
        canvas.translate(x + tileWidth, 0);
        canvas.scale(-1, 1);
        canvas.drawImageRect(
            img, src, ui.Rect.fromLTWH(0, 0, tileWidth, tileHeight), paint);
        canvas.restore();
      } else {
        canvas.drawImageRect(
            img, src, ui.Rect.fromLTWH(x, 0, tileWidth, tileHeight), paint);
      }
      flip = !flip;
    }
    // Gloom scrim: backdrop sinks into atmosphere, seams die, and fake
    // "platforms" baked into the art stop competing with real geometry.
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.x, size.y),
        ui.Paint()..color = const ui.Color(0xB312100C));
  }
}
