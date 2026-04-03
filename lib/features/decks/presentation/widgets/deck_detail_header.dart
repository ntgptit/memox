import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/navigation/breadcrumb_bar.dart';
import 'package:memox/shared/widgets/progress/mastery_bar.dart';

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
  Widget build(BuildContext context) => SliverAppBar(
    pinned: true,
    expandedHeight: _expandedHeight(context),
    title: showCollapsedTitle
        ? Text(deckName, maxLines: 1, overflow: TextOverflow.ellipsis)
        : null,
    actions: [
      IconButton(
        tooltip: context.l10n.deleteDeckAction,
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline),
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

  double _expandedHeight(BuildContext context) => context.isCompact
      ? SizeTokens.deckDetailHeaderHeightCompact
      : SizeTokens.deckDetailHeaderHeight;
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
