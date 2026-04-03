import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/navigation/breadcrumb_bar.dart';
import 'package:memox/shared/widgets/navigation/top_bar_icon_button.dart';
import 'package:memox/shared/widgets/progress/mastery_bar.dart';

double _expandedHeaderHeight(BuildContext context, bool showMasteryBar) {
  if (!context.isCompact) {
    return SizeTokens.deckDetailHeaderHeight;
  }

  if (showMasteryBar) {
    return SizeTokens.deckDetailHeaderHeightCompact;
  }

  return SizeTokens.deckDetailHeaderHeightCompact - SizeTokens.avatarLg;
}

class DeckDetailHeader extends StatelessWidget {
  const DeckDetailHeader({
    required this.deckName,
    required this.summary,
    required this.breadcrumb,
    required this.masteryPercentage,
    required this.showMasteryBar,
    required this.showCollapsedTitle,
    required this.onDelete,
    super.key,
  });

  final String deckName;
  final String summary;
  final List<BreadcrumbSegment> breadcrumb;
  final double masteryPercentage;
  final bool showMasteryBar;
  final bool showCollapsedTitle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final backTooltip = MaterialLocalizations.of(context).backButtonTooltip;

    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leadingWidth: TopBarIconButton.slotWidth,
      leading: TopBarIconButton(
        tooltip: backTooltip,
        onPressed: () => context.pop<void>(),
        icon: Icons.arrow_back_outlined,
        alignment: Alignment.centerLeft,
      ),
      expandedHeight: _expandedHeaderHeight(context, showMasteryBar),
      title: showCollapsedTitle
          ? Text(deckName, maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      actionsPadding: EdgeInsets.zero,
      actions: [
        TopBarIconButton(
          tooltip: context.l10n.deleteDeckAction,
          onPressed: onDelete,
          icon: Icons.delete_outline,
          alignment: Alignment.centerRight,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.fromLTRB(
            context.screenType.screenPadding,
            SizeTokens.appBarHeight + SpacingTokens.sm,
            context.screenType.screenPadding,
            SpacingTokens.md,
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: _DeckDetailHeaderBody(
              deckName: deckName,
              summary: summary,
              breadcrumb: breadcrumb,
              masteryPercentage: masteryPercentage,
              showMasteryBar: showMasteryBar,
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckDetailHeaderBody extends StatelessWidget {
  const _DeckDetailHeaderBody({
    required this.deckName,
    required this.summary,
    required this.breadcrumb,
    required this.masteryPercentage,
    required this.showMasteryBar,
  });

  final String deckName;
  final String summary;
  final List<BreadcrumbSegment> breadcrumb;
  final double masteryPercentage;
  final bool showMasteryBar;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      BreadcrumbBar(segments: breadcrumb),
      const SizedBox(height: SpacingTokens.md),
      Text(
        deckName,
        maxLines: context.isCompact ? 2 : 1,
        overflow: TextOverflow.ellipsis,
        style: context.appTextStyles.appTitle,
      ),
      const SizedBox(height: SpacingTokens.xs),
      Text(
        summary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodyMedium,
      ),
      if (showMasteryBar) ...[
        const SizedBox(height: SpacingTokens.md),
        Text(
          context.l10n.deckMasteryLabel((masteryPercentage * 100).round()),
          style: context.textTheme.labelMedium,
        ),
        const SizedBox(height: SpacingTokens.xs),
        MasteryBar(percentage: masteryPercentage, animate: false),
      ],
    ],
  );
}
