import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';

/// White kill-flash: six pixel shards burst outward on defeat. Cheap, loud.
class KillBurst extends PositionComponent {
  KillBurst({required Vector2 position, this.color = BroskieColors.bone}) : super(position: position);

  final Color color;
  double _timer = lifetime;
  static const double lifetime = 0.28;
  static final List<Vector2> _dirs = List.generate(6, (i) {
    final a = i * pi / 3 - pi / 2;
    return Vector2(cos(a), sin(a));
  });

  @override
  void update(double dt) {
    _timer -= dt;
    if (_timer <= 0) removeFromParent();
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final t = (1 - _timer / lifetime).clamp(0.0, 1.0);
    final paint = Paint()..color = color.withOpacity(1 - t);
    for (final d in _dirs) {
      canvas.drawRect(Rect.fromLTWH(d.x * 34 * t - 2, d.y * 34 * t - 2, 4, 4), paint);
    }
  }
}
