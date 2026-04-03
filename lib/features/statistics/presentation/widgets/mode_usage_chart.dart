import 'package:flutter/material.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/progress/count_up_text.dart';
import 'package:memox/shared/widgets/progress/progress_bar.dart';

class ModeUsageChart extends StatelessWidget {
  const ModeUsageChart({required this.modeUsage, super.key});

  final Map<StudyMode, double> modeUsage;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.statisticsModeUsageTitle,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: SpacingTokens.lg),
        ...StudyMode.values.map(
          (mode) => _ModeUsageRow(mode: mode, percentage: modeUsage[mode] ?? 0),
        ),
      ],
    ),
  );
}

class _ModeUsageRow extends StatelessWidget {
  const _ModeUsageRow({required this.mode, required this.percentage});

  final StudyMode mode;
  final double percentage;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: SizeTokens.listItemCompact,
    child: Row(
      children: [
        Expanded(flex: 3, child: Text(mode.label(context.l10n))),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          flex: 5,
          child: ProgressBar(
            progress: percentage / 100,
            height: SizeTokens.statisticsModeBarHeight,
          ),
        ),
        const SizedBox(width: SpacingTokens.md),
        CountUpText(
          endValue: percentage.round(),
          style: context.textTheme.bodyMedium!,
          suffix: '%',
        ),
      ],
    ),
  );
}
