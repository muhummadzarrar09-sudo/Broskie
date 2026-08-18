import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:broskie_game/game/broskie_game.dart';

/// AI-art stage backdrop, tiled horizontally at native aspect ratio and
/// bottom-aligned with the street line. Renders behind all gameplay
/// (priority -50); the sky parallax sits further back at -100.
///
/// If the image fails to load the component renders nothing and the
/// parallax sky remains visible, so stages always have a background.
class StageBackdrop extends PositionComponent with HasGameRef<BroskieGame> {
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
      _image = await gameRef.images.load(imagePath);
    } catch (_) {
      // Missing art falls back to the sky parallax automatically.
    }
  }

  @override
  void render(Canvas canvas) {
    final img = _image;
    if (img == null) return;
    final tileWidth = img.width * (tileHeight / img.height);
    final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    final paint = Paint()..filterQuality = FilterQuality.low;
    for (double x = 0; x < size.x; x += tileWidth) {
      canvas.drawImageRect(img, src, Rect.fromLTWH(x, 0, tileWidth, tileHeight), paint);
    }
  }
}
