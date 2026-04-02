import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/chips/streak_chip.dart';
import 'package:memox/shared/widgets/progress/progress_bar.dart';

class StudyTopBar extends StatelessWidget implements PreferredSizeWidget {
  const StudyTopBar({
    required this.title,
    required this.current,
    required this.total,
    required this.onClose,
    this.streak,
    this.streakThreshold = 2,
    super.key,
  });

  final String title;
  final int current;
  final int total;
  final int? streak;
  final int streakThreshold;
  final VoidCallback onClose;

  @override
  Size get preferredSize => const Size.fromHeight(
    SizeTokens.appBarHeight + SizeTokens.progressBarHeight,
  );

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;

    return Material(
      color: context.colors.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StudyTopBarHeader(
              title: title,
              current: current,
              total: total,
              streak: streak,
              streakThreshold: streakThreshold,
              onClose: onClose,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: ProgressBar(progress: progress),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyTopBarHeader extends StatelessWidget {
  const _StudyTopBarHeader({
    required this.title,
    required this.current,
    required this.total,
    required this.streak,
    required this.streakThreshold,
    required this.onClose,
  });

  final String title;
  final int current;
  final int total;
  final int? streak;
  final int streakThreshold;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final showStreak = (streak ?? 0) >= streakThreshold;

    return SizedBox(
      height: SizeTokens.appBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
        child: Row(
          children: [
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_outlined),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: context.textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(
                    '$current/$total',
                    style: context.appTextStyles.progressCount.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: SizeTokens.touchTarget + SpacingTokens.xxl,
              child: Align(
                alignment: Alignment.centerRight,
                child: showStreak
                    ? StreakChip(count: streak!)
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
