import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class StageAtmosphere extends PositionComponent {
  StageAtmosphere({
    required Vector2 levelSize,
    required this.stageIndex,
    required this.accent,
    required this.reducedEffects,
  }) : super(size: levelSize, priority: -30) {
    final random = math.Random(9000 + stageIndex);
    final count = reducedEffects ? 28 : 85;
    for (var i = 0; i < count; i++) {
      _particles.add(
        _AtmosphereParticle(
          x: random.nextDouble() * levelSize.x,
          y: random.nextDouble() * levelSize.y,
          speed: 25 + random.nextDouble() * 110,
          size: 1 + random.nextDouble() * 3,
          phase: random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  final int stageIndex;
  final Color accent;
  final bool reducedEffects;
  final List<_AtmosphereParticle> _particles = [];
  double _time = 0;

  @override
  void update(double dt) {
    _time += dt;
    for (final particle in _particles) {
      switch (stageIndex) {
        case 0:
          particle.x += particle.speed * 0.16 * dt;
          particle.y += math.sin(_time + particle.phase) * 4 * dt;
        case 1:
          particle.y -= particle.speed * dt;
          particle.x += math.sin(_time * 2 + particle.phase) * 7 * dt;
        case 2:
          particle.y += particle.speed * 1.8 * dt;
          particle.x -= particle.speed * 0.22 * dt;
        default:
          particle.y += particle.speed * 0.45 * dt;
          particle.x += math.sin(_time * 3 + particle.phase) * 12 * dt;
      }
      if (particle.x < 0) {
        particle.x += width;
      }
      if (particle.x > width) {
        particle.x -= width;
      }
      if (particle.y < 0) {
        particle.y += height;
      }
      if (particle.y > height) {
        particle.y -= height;
      }
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    for (final particle in _particles) {
      switch (stageIndex) {
        case 0:
          canvas.drawCircle(
            Offset(particle.x, particle.y),
            particle.size * 1.5,
            Paint()..color = accent.withValues(alpha: 0.16),
          );
        case 1:
          canvas.drawLine(
            Offset(particle.x, particle.y),
            Offset(particle.x + 3, particle.y - particle.size * 3),
            Paint()
              ..color = const Color(0xAAFF8A32)
              ..strokeWidth = particle.size,
          );
        case 2:
          canvas.drawLine(
            Offset(particle.x, particle.y),
            Offset(particle.x - 7, particle.y + 18),
            Paint()
              ..color = const Color(0x6655EFFF)
              ..strokeWidth = particle.size * 0.7,
          );
        default:
          canvas.drawRect(
            Rect.fromLTWH(
              particle.x,
              particle.y,
              particle.size * 2.2,
              particle.size * 2.2,
            ),
            Paint()..color = accent.withValues(alpha: 0.48),
          );
      }
    }

    if (!reducedEffects) {
      _renderTraffic(canvas);
    }
  }

  void _renderTraffic(Canvas canvas) {
    for (var i = 0; i < 4; i++) {
      final direction = i.isEven ? 1.0 : -1.0;
      final travel = (_time * (55 + i * 18) + i * 830) % (width + 300);
      final x = direction > 0 ? travel - 150 : width - travel + 150;
      final y = 95.0 + i * 37;
      final vehicleColor = i.isEven ? accent : const Color(0xFFFF3EC8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 38, 9),
          const Radius.circular(5),
        ),
        Paint()..color = vehicleColor.withValues(alpha: 0.65),
      );
      canvas.drawLine(
        Offset(x - direction * 8, y + 4),
        Offset(x - direction * 42, y + 4),
        Paint()
          ..color = vehicleColor.withValues(alpha: 0.22)
          ..strokeWidth = 3,
      );
    }
  }
}

class _AtmosphereParticle {
  _AtmosphereParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.phase,
  });

  double x;
  double y;
  final double speed;
  final double size;
  final double phase;
}
