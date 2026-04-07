import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/statistics/domain/entities/study_stats.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/progress/count_up_text.dart';

class StreakHeroCard extends StatelessWidget {
  const StreakHeroCard({required this.stats, super.key});

  final StudyStats stats;

  @override
  Widget build(BuildContext context) => AppCard(
    backgroundColor: context.colors.surfaceContainerHigh,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CountUpText(
              endValue: stats.streak,
              style: context.appTextStyles.statNumber.copyWith(
                color: context.colors.primary,
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Icon(
              Icons.local_fire_department_outlined,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                context.l10n.statisticsStreakLabel,
                style: context.textTheme.headlineMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: SpacingTokens.xs,
          children: [
            Text(
              context.l10n.statisticsTodayPrefix,
              style: context.textTheme.bodySmall,
            ),
            CountUpText(
              endValue: stats.cardsToday,
              style: context.textTheme.bodySmall!,
            ),
            Text(
              context.l10n.statisticsCardsUnit,
              style: context.textTheme.bodySmall,
            ),
            Icon(
              Icons.circle_outlined,
              size: SizeTokens.iconXs,
              color: context.colors.onSurfaceVariant,
            ),
            CountUpText(
              endValue: stats.minutesToday,
              style: context.textTheme.bodySmall!,
            ),
            Text(
              context.l10n.statisticsMinutesUnit,
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    ),
  );
}
