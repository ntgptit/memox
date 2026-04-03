import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class MasteryDonutPainter extends CustomPainter {
  MasteryDonutPainter({
    required this.values,
    required this.colors,
    required this.progress,
  });

  final List<int> values;
  final List<Color> colors;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<int>(0, (sum, value) => sum + value);
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = SizeTokens.statisticsDonutStroke
      ..strokeCap = StrokeCap.round;
    var startAngle = -math.pi / 2;

    for (var index = 0; index < values.length; index++) {
      final sweep = total == 0 ? 0.0 : ((values[index] / total) * math.pi * 2);
      paint.color = colors[index];
      canvas.drawArc(
        rect.deflate(SizeTokens.statisticsDonutStroke),
        startAngle,
        sweep * progress,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant MasteryDonutPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.progress != progress;
}
