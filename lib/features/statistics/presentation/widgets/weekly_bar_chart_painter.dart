import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/date_utils.dart';
import 'package:memox/features/statistics/domain/entities/daily_activity.dart';

class WeeklyBarChartPainter extends CustomPainter {
  WeeklyBarChartPainter({
    required this.activities,
    required this.today,
    required this.todayColor,
    required this.barColor,
    required this.progress,
  });

  final List<DailyActivity> activities;
  final DateTime today;
  final Color todayColor;
  final Color barColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = math.max(
      1,
      activities.fold<int>(0, (max, item) => math.max(max, item.cardsStudied)),
    );
    final slotWidth = size.width / activities.length;
    final barWidth = math.max(slotWidth - SpacingTokens.md, SpacingTokens.xl);
    final paint = Paint();

    for (var index = 0; index < activities.length; index++) {
      final activity = activities[index];
      final localProgress = _localProgress(index);
      final barHeight =
          size.height * (activity.cardsStudied / maxValue) * localProgress;
      final left = (slotWidth * index) + ((slotWidth - barWidth) / 2);
      final rect = Rect.fromLTWH(
        left,
        size.height - barHeight,
        barWidth,
        barHeight,
      );
      paint.color = AppDateUtils.isSameDay(activity.date, today)
          ? todayColor
          : barColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(RadiusTokens.chip)),
        paint,
      );
    }
  }

  double _localProgress(int index) {
    final start = index * 0.1;
    final normalized = (progress - start) / (1 - start);
    return normalized.clamp(0, 1);
  }

  @override
  bool shouldRepaint(covariant WeeklyBarChartPainter oldDelegate) =>
      oldDelegate.activities != activities ||
      oldDelegate.progress != progress ||
      oldDelegate.today != today ||
      oldDelegate.todayColor != todayColor ||
      oldDelegate.barColor != barColor;
}
