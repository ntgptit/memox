import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/chips/streak_chip.dart';
import 'package:memox/shared/widgets/navigation/top_bar_icon_button.dart';
import 'package:memox/shared/widgets/progress/progress_bar.dart';

class StudyTopBar extends StatelessWidget implements PreferredSizeWidget {
  const StudyTopBar({
    required this.title,
    required this.current,
    required this.total,
    required this.onClose,
    this.streak,
    this.streakThreshold = 2,
    this.subtitle,
    this.trailing,
    this.showProgress = true,
    this.showCount = true,
    super.key,
  });

  final String title;
  final int current;
  final int total;
  final int? streak;
  final int streakThreshold;
  final VoidCallback onClose;
  final String? subtitle;
  final Widget? trailing;
  final bool showProgress;
  final bool showCount;

  @override
  Size get preferredSize => Size.fromHeight(
    SizeTokens.appBarHeight + _studyTopBarMetaHeight(subtitle, showProgress),
  );

  @override
  Widget build(BuildContext context) => Material(
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
            trailing: trailing,
            showCount: showCount,
          ),
          _StudyTopBarMeta(
            subtitle: subtitle,
            showProgress: showProgress,
            current: current,
            total: total,
          ),
        ],
      ),
    ),
  );
}

double _studyTopBarMetaHeight(String? subtitle, bool showProgress) {
  if (subtitle != null || showProgress) {
    return SizeTokens.studyTopBarMetaHeight;
  }

  return 0;
}

class _StudyTopBarHeader extends StatelessWidget {
  const _StudyTopBarHeader({
    required this.title,
    required this.current,
    required this.total,
    required this.streak,
    required this.streakThreshold,
    required this.onClose,
    required this.trailing,
    required this.showCount,
  });

  final String title;
  final int current;
  final int total;
  final int? streak;
  final int streakThreshold;
  final VoidCallback onClose;
  final Widget? trailing;
  final bool showCount;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: SizeTokens.appBarHeight,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      child: Row(
        children: [
          TopBarIconButton(
            tooltip: context.l10n.exitAction,
            onPressed: onClose,
            icon: Icons.close_outlined,
            alignment: Alignment.centerLeft,
            slotWidth: TopBarIconButton.balancedSlotWidth,
          ),
          Expanded(
            child: _StudyTopBarTitle(
              title: title,
              current: current,
              total: total,
              showCount: showCount,
            ),
          ),
          SizedBox(
            width: TopBarIconButton.balancedSlotWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: _studyTopBarTrailingWidget(
                trailing: trailing,
                streak: streak,
                streakThreshold: streakThreshold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _studyTopBarTrailingWidget({
  required Widget? trailing,
  required int? streak,
  required int streakThreshold,
}) {
  if (trailing != null) {
    return trailing;
  }

  if ((streak ?? 0) < streakThreshold) {
    return const SizedBox.shrink();
  }

  return KeyedSubtree(
    key: ValueKey<int>(streak!),
    child: StreakChip(count: streak),
  );
}

class _StudyTopBarTitle extends StatelessWidget {
  const _StudyTopBarTitle({
    required this.title,
    required this.current,
    required this.total,
    required this.showCount,
  });

  final String title;
  final int current;
  final int total;
  final bool showCount;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Flexible(
        child: Text(
          title,
          style: context.textTheme.titleSmall,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (showCount)
        Padding(
          padding: const EdgeInsets.only(left: SpacingTokens.sm),
          child: Text(
            '$current/$total',
            style: context.appTextStyles.progressCount.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
    ],
  );
}

class _StudyTopBarMeta extends StatelessWidget {
  const _StudyTopBarMeta({
    required this.subtitle,
    required this.showProgress,
    required this.current,
    required this.total,
  });

  final String? subtitle;
  final bool showProgress;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (subtitle == null && !showProgress) {
      return const SizedBox.shrink();
    }

    final progress = total == 0 ? 0.0 : current / total;
    return SizedBox(
      height: SizeTokens.studyTopBarMetaHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
        child: subtitle != null
            ? Align(
                alignment: Alignment.centerLeft,
                child: Text(subtitle!, style: context.appTextStyles.breadcrumb),
              )
            : ProgressBar(progress: progress),
      ),
    );
  }
}
