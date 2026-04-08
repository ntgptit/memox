import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/review_provider.dart';
import 'package:memox/features/study/presentation/widgets/review_round_view.dart';
import 'package:memox/features/study/presentation/widgets/study_mistakes_panel.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';
import 'package:memox/shared/widgets/feedback/session_complete_view.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/navigation/study_top_bar.dart';

class ReviewModeScreen extends ConsumerWidget {
  const ReviewModeScreen({required this.deckId, super.key});

  final int deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewSessionProvider(deckId));

    return AppAsyncBuilder<ReviewState>(
      value: state,
      onRetry: () {
        unawaited(
          ref.read(reviewSessionProvider(deckId).notifier).startSession(),
        );
      },
      onData: (data) => AppScaffold(
        appBar: StudyTopBar(
          title: context.l10n.modeReview,
          current: data.isComplete ? data.totalCards : data.displayIndex,
          total: data.totalCards,
          onClose: () => unawaited(_handleClose(context)),
          showCount: data.cards.isNotEmpty,
          showProgress: data.cards.isNotEmpty && !data.isComplete,
        ),
        applyBottomPadding: false,
        applyHorizontalPadding: false,
        body: _buildBody(context, ref, deckId, data),
      ),
    );
  }

  Future<void> _handleClose(BuildContext context) async {
    final confirmed = await context.showConfirmDialog(
      title: context.l10n.exitSessionTitle,
      message: context.l10n.exitSessionMessage,
      confirmText: context.l10n.exitAction,
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      context.pop<void>();
    }
  }
}

Widget _buildBody(
  BuildContext context,
  WidgetRef ref,
  int deckId,
  ReviewState state,
) {
  final difficultCards = _reviewMistakes(state);

  if (state.cards.isEmpty) {
    return EmptyStateView(
      icon: Icons.autorenew_outlined,
      title: context.l10n.modeReview,
      subtitle: context.l10n.reviewEmptySubtitle,
    );
  }

  if (state.isComplete) {
    return SessionCompleteView(
      title: context.l10n.reviewCompleteTitle(state.totalCards),
      stats: [
        SessionStat(
          label: context.l10n.reviewRatingAgain,
          icon: Icons.refresh_outlined,
          value: '${state.againCount}',
          valueColor: context.customColors.ratingAgain,
        ),
        SessionStat(
          label: context.l10n.reviewRatingHard,
          icon: Icons.speed_outlined,
          value: '${state.hardCount}',
          valueColor: context.customColors.ratingHard,
        ),
        SessionStat(
          label: context.l10n.reviewRatingGood,
          icon: Icons.thumb_up_alt_outlined,
          value: '${state.goodCount}',
          valueColor: context.customColors.ratingGood,
        ),
        SessionStat(
          label: context.l10n.reviewRatingEasy,
          icon: Icons.bolt_outlined,
          value: '${state.easyCount}',
          valueColor: context.customColors.ratingEasy,
        ),
      ],
      primaryAction: SessionAction(
        label: context.l10n.doneAction,
        onTap: () => context.pop<void>(),
      ),
      extraContent: Column(
        children: [
          Text(
            context.l10n.reviewCompletionSummary(
              state.againCount,
              state.hardCount,
              state.goodCount,
              state.easyCount,
            ),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (difficultCards.isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.lg),
            StudyMistakesPanel(items: difficultCards),
          ],
        ],
      ),
    );
  }

  return ReviewRoundView(
    state: state,
    onToggleFlip: () =>
        ref.read(reviewSessionProvider(deckId).notifier).toggleFlip(),
    onRate: (rating) =>
        ref.read(reviewSessionProvider(deckId).notifier).rate(rating),
  );
}

List<StudyMistakeItem> _reviewMistakes(ReviewState state) {
  final cardIds = state.results
      .where((result) => result.rating == ReviewRating.again)
      .map((result) => result.cardId)
      .toSet();
  return state.cards
      .where((card) => cardIds.contains(card.id))
      .map((card) => (front: card.front, back: card.back))
      .toList(growable: false);
}
