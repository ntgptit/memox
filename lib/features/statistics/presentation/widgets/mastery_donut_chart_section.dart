import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/statistics/domain/entities/mastery_breakdown.dart';
import 'package:memox/features/statistics/presentation/widgets/mastery_donut_painter.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/progress/count_up_text.dart';

class MasteryDonutChartSection extends StatelessWidget {
  const MasteryDonutChartSection({required this.mastery, super.key});

  final MasteryBreakdown mastery;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.statisticsMasteryTitle,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: SpacingTokens.lg),
        Center(
          child: SizedBox.square(
            dimension: SizeTokens.statisticsDonutSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: DurationTokens.chartDraw,
                  builder: (context, value, _) => CustomPaint(
                    painter: MasteryDonutPainter(
                      values: [
                        mastery.known,
                        mastery.learning,
                        mastery.newCards,
                      ],
                      colors: [
                        context.customColors.masteryHigh,
                        context.customColors.masteryMid,
                        context.colors.onSurfaceVariant,
                      ],
                      progress: value,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CountUpText(
                      endValue: mastery.total,
                      style: context.appTextStyles.statNumberMd,
                    ),
                    Text(
                      context.l10n.cardsTitle,
                      style: context.textTheme.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        Wrap(
          spacing: SpacingTokens.lg,
          runSpacing: SpacingTokens.sm,
          children: [
            _MasteryLegend(
              mastery: mastery,
              knownColor: context.customColors.masteryHigh,
              learningColor: context.customColors.masteryMid,
              newColor: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ],
    ),
  );
}

class _MasteryLegend extends StatelessWidget {
  const _MasteryLegend({
    required this.mastery,
    required this.knownColor,
    required this.learningColor,
    required this.newColor,
  });

  final MasteryBreakdown mastery;
  final Color knownColor;
  final Color learningColor;
  final Color newColor;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: SpacingTokens.lg,
    runSpacing: SpacingTokens.sm,
    children: [
      _MasteryLegendItem(
        color: knownColor,
        label: context.l10n.knownLabel,
        count: mastery.known,
      ),
      _MasteryLegendItem(
        color: learningColor,
        label: context.l10n.statusLearning,
        count: mastery.learning,
      ),
      _MasteryLegendItem(
        color: newColor,
        label: context.l10n.newLabel,
        count: mastery.newCards,
      ),
    ],
  );
}

class _MasteryLegendItem extends StatelessWidget {
  const _MasteryLegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.circle_outlined,
        color: color,
        size: SizeTokens.statusDotSizeLg,
      ),
      const SizedBox(width: SpacingTokens.xs),
      Text(label, style: context.textTheme.bodySmall),
      const SizedBox(width: SpacingTokens.xs),
      CountUpText(endValue: count, style: context.textTheme.bodySmall!),
    ],
  );
}
