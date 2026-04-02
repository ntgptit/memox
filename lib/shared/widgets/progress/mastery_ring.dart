import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class MasteryRing extends StatelessWidget {
  const MasteryRing({
    required this.percentage,
    this.size = SizeTokens.masteryRingSize,
    this.strokeWidth = SizeTokens.masteryRingStroke,
    this.showPercentText = false,
    super.key,
  });

  final double percentage;
  final double size;
  final double strokeWidth;
  final bool showPercentText;

  @override
  Widget build(BuildContext context) {
    final safePercentage = percentage.clamp(0.0, 1.0);

    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: safePercentage),
        duration: DurationTokens.chartDraw,
        builder: (context, value, _) => Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: _MasteryRingPainter(
                progress: value,
                strokeWidth: strokeWidth,
                trackColor: context.colors.surfaceContainerHighest,
                progressColor: context.colors.primary,
              ),
            ),
            if (showPercentText)
              Text(
                '${(value * 100).round()}%',
                style: context.appTextStyles.nextReviewTime,
              ),
          ],
        ),
      ),
    );
  }
}

class _MasteryRingPainter extends CustomPainter {
  const _MasteryRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawArc(rect, -math.pi / 2, math.pi * 2, false, trackPaint)
      ..drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        progressPaint,
      );
  }

  @override
  bool shouldRepaint(covariant _MasteryRingPainter other) =>
      progress != other.progress ||
      strokeWidth != other.strokeWidth ||
      trackColor != other.trackColor ||
      progressColor != other.progressColor;
}
