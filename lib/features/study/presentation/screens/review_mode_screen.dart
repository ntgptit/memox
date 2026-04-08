import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/domain/support/flashcard_flags.dart';
import 'package:memox/features/cards/presentation/screens/card_edit_screen.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/review_provider.dart';
import 'package:memox/features/study/presentation/widgets/review_round_view.dart';
import 'package:memox/features/study/presentation/widgets/study_mistakes_panel.dart';
import 'package:memox/features/study/presentation/widgets/study_next_deck_button.dart';
import 'package:memox/shared/widgets/buttons/icon_action_button.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';
import 'package:memox/shared/widgets/feedback/session_complete_view.dart';
import 'package:memox/shared/widgets/feedback/toast.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/navigation/study_top_bar.dart';

class ReviewModeScreen extends ConsumerStatefulWidget {
  const ReviewModeScreen({required this.deckId, super.key});

  final int deckId;

  @override
  ConsumerState<ReviewModeScreen> createState() => _ReviewModeScreenState();
}

class _ReviewModeScreenState extends ConsumerState<ReviewModeScreen> {
  var _lastActionSequence = 0;

  @override
  Widget build(BuildContext context) {
    final provider = reviewSessionProvider(widget.deckId);
    return AppAsyncBuilder<ReviewState>(
      value: ref.watch(provider),
      onRetry: () {
        unawaited(ref.read(provider.notifier).startSession());
      },
      onData: (data) {
        _scheduleUndoSnackBar(context, data);
        return AppScaffold(
          appBar: StudyTopBar(
            title: context.l10n.modeReview,
            current: data.isComplete ? data.totalCards : data.displayIndex,
            total: data.totalCards,
            onClose: () => unawaited(_handleClose(context)),
            trailing: data.currentCard == null
                ? null
                : IconActionButton(
                    icon: Icons.flag_outlined,
                    tooltip: data.currentCard!.isFlagged
                        ? context.l10n.reviewUnflagAction
                        : context.l10n.reviewFlagAction,
                    onTap: () => unawaited(_toggleFlag(context)),
                  ),
            showCount: data.cards.isNotEmpty,
            showProgress: data.cards.isNotEmpty && !data.isComplete,
          ),
          applyBottomPadding: false,
          applyHorizontalPadding: false,
          body: _buildBody(context, ref, widget.deckId, data),
        );
      },
    );
  }

  Future<void> _handleClose(BuildContext context) async {
    final confirmed = await context.showConfirmDialog(
      title: context.l10n.exitSessionTitle,
      message: context.l10n.exitSessionMessage,
      confirmText: context.l10n.exitAction,
      isDestructive: true,
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final store = await ref.read(activeStudySessionStoreProvider.future);
    await store.clearIfMatches(deckId: widget.deckId, mode: StudyMode.review);

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  void _showUndoSnackBar(BuildContext context, ReviewRating rating) {
    Toast.show(
      context,
      context.l10n.reviewUndoMessage(_ratingLabel(context, rating)),
      actionLabel: context.l10n.undoAction,
      onAction: () {
        unawaited(
          ref
              .read(reviewSessionProvider(widget.deckId).notifier)
              .undoLastRating(),
        );
      },
    );
  }

  Future<void> _toggleFlag(BuildContext context) async {
    final isFlagged = await ref
        .read(reviewSessionProvider(widget.deckId).notifier)
        .toggleFlag();

    if (isFlagged == null || !context.mounted) {
      return;
    }

    context.showSnackBar(
      isFlagged
          ? context.l10n.cardFlaggedMessage
          : context.l10n.cardUnflaggedMessage,
    );
  }

  void _scheduleUndoSnackBar(BuildContext context, ReviewState state) {
    final rating = state.lastRated;

    if (rating == null) {
      return;
    }

    if (state.lastActionSequence == 0 ||
        state.lastActionSequence == _lastActionSequence) {
      return;
    }

    _lastActionSequence = state.lastActionSequence;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _showUndoSnackBar(context, rating);
    });
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
        onTap: () => Navigator.of(context).pop(),
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
            StudyMistakesPanel(
              items: difficultCards,
              onTapItem: (item) => unawaited(
                context.push(CardEditScreen.routeLocation(deckId, item.cardId)),
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.lg),
          StudyNextDeckButton(currentDeckId: deckId, mode: StudyMode.review),
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

String _ratingLabel(BuildContext context, ReviewRating rating) =>
    switch (rating) {
      ReviewRating.again => context.l10n.reviewRatingAgain,
      ReviewRating.hard => context.l10n.reviewRatingHard,
      ReviewRating.good => context.l10n.reviewRatingGood,
      ReviewRating.easy => context.l10n.reviewRatingEasy,
    };

List<StudyMistakeItem> _reviewMistakes(ReviewState state) {
  final cardIds = state.results
      .where((result) => result.rating == ReviewRating.again)
      .map((result) => result.cardId)
      .toSet();
  return state.cards
      .where((card) => cardIds.contains(card.id))
      .map((card) => (cardId: card.id, front: card.front, back: card.back))
      .toList(growable: false);
}
