import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/responsive/responsive_padding.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/domain/entities/deck_stats.dart';
import 'package:memox/features/decks/presentation/models/deck_detail_view_state.dart';
import 'package:memox/features/decks/presentation/widgets/deck_stats_grid.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class DeckDetailOverview extends StatelessWidget {
  const DeckDetailOverview({
    required this.stats,
    required this.viewState,
    required this.onStudyDueCards,
    required this.onChooseStudyMode,
    required this.onAddFirstCard,
    required this.onImportBatch,
    super.key,
  });

  final DeckStats stats;
  final DeckDetailViewState viewState;
  final VoidCallback onStudyDueCards;
  final VoidCallback onChooseStudyMode;
  final VoidCallback onAddFirstCard;
  final VoidCallback onImportBatch;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: ResponsivePadding.horizontal(context),
    sliver: SliverList.list(children: _children(context)),
  );

  List<Widget> _children(BuildContext context) {
    if (viewState == DeckDetailViewState.empty) {
      return [
        _DeckActionCard(
          icon: Icons.style_outlined,
          title: context.l10n.cardsEmptyTitle,
          subtitle: context.l10n.deckEmptySummary,
          primaryLabel: context.l10n.addFirstCardAction,
          secondaryLabel: context.l10n.importBatchAction,
          onPrimaryTap: onAddFirstCard,
          onSecondaryTap: onImportBatch,
        ),
      ];
    }

    final children = <Widget>[
      DeckStatsGrid(stats: stats),
      const SizedBox(height: SpacingTokens.lg),
    ];

    if (viewState == DeckDetailViewState.caughtUp) {
      children.add(
        _DeckActionCard(
          icon: Icons.check_circle_outline,
          title: context.l10n.deckCaughtUpTitle,
          subtitle: context.l10n.deckCaughtUpBody,
          primaryLabel: context.l10n.chooseStudyModeButton,
          onPrimaryTap: onChooseStudyMode,
        ),
      );
      return children;
    }

    children
      ..add(
        PrimaryButton(
          label: context.l10n.studyDueCardsAction(stats.due),
          onPressed: onStudyDueCards,
        ),
      )
      ..add(const SizedBox(height: SpacingTokens.sm))
      ..add(
        Align(
          alignment: Alignment.centerLeft,
          child: TextLinkButton(
            label: context.l10n.chooseStudyModeAction,
            onTap: onChooseStudyMode,
          ),
        ),
      );
    return children;
  }
}

class _DeckActionCard extends StatelessWidget {
  const _DeckActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimaryTap,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(SpacingTokens.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(
            dimension: SizeTokens.avatarMd,
            child: Icon(icon, size: SizeTokens.iconMd),
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Text(title, style: context.textTheme.titleMedium),
        const SizedBox(height: SpacingTokens.sm),
        Text(subtitle, style: context.textTheme.bodyMedium),
        const SizedBox(height: SpacingTokens.lg),
        PrimaryButton(
          label: primaryLabel,
          onPressed: onPrimaryTap,
          height: SizeTokens.buttonHeight,
        ),
        if (secondaryLabel != null && onSecondaryTap != null) ...[
          const SizedBox(height: SpacingTokens.sm),
          SecondaryButton(
            label: secondaryLabel!,
            onPressed: onSecondaryTap,
            height: SizeTokens.buttonHeight,
          ),
        ],
      ],
    ),
  );
}
