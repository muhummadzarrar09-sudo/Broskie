import 'package:flutter/material.dart';

/// The design center, in code. See DESIGN.md — Beat vs Barcode.
/// Locked palette, hard-shadow type, scanlines, pixel glyphs.
class BroskieColors {
  static const night = Color(0xFF0F0C20);
  static const cyan = Color(0xFF00E5FF);
  static const magenta = Color(0xFFFF3FA4);
  static const amber = Color(0xFFFFB800);
  static const bone = Color(0xFFF2F2F2);
  static const go = Color(0xFF00FF66); // semantic: exits, success
}

/// Headline style with the law: 2px hard offset shadow, zero blur.
TextStyle broskieHeadline({
  double size = 22,
  Color color = BroskieColors.cyan,
  double letterSpacing = 3,
}) {
  return TextStyle(
    color: color,
    fontSize: size,
    fontWeight: FontWeight.w900,
    fontFamily: 'monospace',
    letterSpacing: letterSpacing,
    shadows: const [Shadow(offset: Offset(2, 2), blurRadius: 0, color: Colors.black)],
  );
}

/// Kit border: 3px chunky, radius never above 8.
BoxDecoration broskiePanel({Color border = BroskieColors.cyan, Color background = Colors.black}) {
  return BoxDecoration(
    color: background.withOpacity(0.92),
    border: Border.all(color: border, width: 3),
    borderRadius: BorderRadius.circular(8),
  );
}

/// CRT signature texture: laid over every overlay.
class ScanlinesPainter extends CustomPainter {
  final double opacity;

  const ScanlinesPainter({this.opacity = 0.06});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(opacity);
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(ScanlinesPainter oldDelegate) => oldDelegate.opacity != opacity;
}

/// Drop-in scanline layer. Non-interactive, always covers its parent.
class ScanlineFill extends StatelessWidget {
  final double opacity;

  const ScanlineFill({super.key, this.opacity = 0.06});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: ScanlinesPainter(opacity: opacity), size: Size.infinite),
    );
  }
}

/// Wraps any overlay in the CRT scanline skin.
Widget broskieOverlayScan(Widget child) {
  return Stack(children: [child, const ScanlineFill()]);
}

/// Pixel heart glyph (diegetic HP — no Material icons on the HUD).
class PixelHeartPainter extends CustomPainter {
  final bool filled;

  const PixelHeartPainter({required this.filled});

  @override
  void paint(Canvas canvas, Size size) {
    const unit = 2.6;
    const pattern = [
      '01100110',
      '11111111',
      '11111111',
      '01111110',
      '00111100',
      '00011000',
    ];
    final body = Paint()..color = filled ? BroskieColors.magenta : Colors.white24;
    for (var row = 0; row < pattern.length; row++) {
      for (var col = 0; col < 8; col++) {
        if (pattern[row][col] == '1') {
          canvas.drawRect(Rect.fromLTWH(col * unit, row * unit, unit, unit), body);
        }
      }
    }
  }

  @override
  bool shouldRepaint(PixelHeartPainter oldDelegate) => oldDelegate.filled != filled;
}

/// Pixel vinyl glyph (diegetic cash — Data Vinyls).
class PixelVinylPainter extends CustomPainter {
  const PixelVinylPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.drawCircle(c, r, Paint()..color = Colors.black);
    canvas.drawCircle(c, r, Paint()
      ..color = BroskieColors.bone.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
    canvas.drawCircle(c, r * 0.42, Paint()..color = BroskieColors.magenta);
    canvas.drawCircle(c, r * 0.14, Paint()..color = BroskieColors.bone);
  }

  @override
  bool shouldRepaint(PixelVinylPainter oldDelegate) => false;
}

/// Deterministic barcode stamp — the villain's signature mark.
void drawBarcode(Canvas canvas, Rect rect, {int seed = 7, Color color = Colors.black}) {
  final paint = Paint()..color = color;
  var rng = seed;
  double x = rect.left;
  while (x < rect.right - 2) {
    rng = (rng * 1103515245 + 12345) & 0x7fffffff;
    final w = 1.0 + (rng % 3);
    if (rng % 5 != 0) {
      final bw = w.clamp(1.0, rect.right - x);
      canvas.drawRect(Rect.fromLTWH(x, rect.top, bw, rect.height), paint);
    }
    x += w + 1.5;
  }
}
