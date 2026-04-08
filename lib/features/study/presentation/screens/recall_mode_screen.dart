import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/presentation/screens/card_edit_screen.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/recall_provider.dart';
import 'package:memox/features/study/presentation/widgets/recall_round_view.dart';
import 'package:memox/features/study/presentation/widgets/study_mistakes_panel.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';
import 'package:memox/shared/widgets/feedback/session_complete_view.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/navigation/study_top_bar.dart';

class RecallModeScreen extends ConsumerStatefulWidget {
  const RecallModeScreen({required this.deckId, super.key});

  final int deckId;

  @override
  ConsumerState<RecallModeScreen> createState() => _RecallModeScreenState();
}

class _RecallModeScreenState extends ConsumerState<RecallModeScreen> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recallSessionProvider(widget.deckId));
    return AppAsyncBuilder<RecallState>(
      value: state,
      onRetry: () {
        unawaited(
          ref
              .read(recallSessionProvider(widget.deckId).notifier)
              .startSession(),
        );
      },
      onData: (data) {
        _syncAnswerController(data.userAnswer);
        return AppScaffold(
          appBar: StudyTopBar(
            title: context.l10n.modeRecall,
            current: data.isComplete ? data.totalCards : data.displayIndex,
            total: data.totalCards,
            onClose: () => unawaited(_handleClose(context)),
          ),
          applyBottomPadding: false,
          applyHorizontalPadding: false,
          body: _buildBody(
            context,
            ref,
            widget.deckId,
            data,
            _answerController,
          ),
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

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void _syncAnswerController(String value) {
    if (_answerController.text == value) {
      return;
    }

    _answerController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}

Widget _buildBody(
  BuildContext context,
  WidgetRef ref,
  int deckId,
  RecallState state,
  TextEditingController controller,
) {
  final difficultCards = _recallMistakes(state);

  if (state.cards.isEmpty) {
    return EmptyStateView(
      icon: Icons.psychology_outlined,
      title: context.l10n.modeRecall,
      subtitle: context.l10n.recallEmptySubtitle,
    );
  }

  if (state.isComplete) {
    return SessionCompleteView(
      title: context.l10n.recallCompleteTitle(state.totalCards),
      stats: [
        SessionStat(
          label: context.l10n.recallRatingGotIt,
          icon: Icons.check_circle_outline,
          value: '${state.gotItCount}',
          valueColor: context.customColors.selfGotIt,
        ),
        SessionStat(
          label: context.l10n.recallRatingPartial,
          icon: Icons.adjust_outlined,
          value: '${state.partialCount}',
          valueColor: context.customColors.selfPartial,
        ),
        SessionStat(
          label: context.l10n.recallRatingMissed,
          icon: Icons.close_outlined,
          value: '${state.missedCount}',
          valueColor: context.customColors.selfMissed,
        ),
      ],
      primaryAction: SessionAction(
        label: context.l10n.doneAction,
        onTap: () => Navigator.of(context).pop(),
      ),
      secondaryAction: state.missedCount == 0 || state.isMissedPracticeSession
          ? null
          : SessionAction(
              label: context.l10n.recallPracticeMissedAction(state.missedCount),
              onTap: () => ref
                  .read(recallSessionProvider(deckId).notifier)
                  .reviewMissedCards(),
            ),
      extraContent: Column(
        children: [
          Text(
            context.l10n.recallCompletionSummary(
              state.gotItCount,
              state.partialCount,
              state.missedCount,
            ),
            style: context.appTextStyles.statNumberSm,
            textAlign: TextAlign.center,
          ),
          if (state.isMissedPracticeSession) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
              context.l10n.recallPracticeMissedSummary,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (difficultCards.isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.lg),
            StudyMistakesPanel(items: difficultCards),
          ],
        ],
      ),
    );
  }

  return RecallRoundView(
    state: state,
    controller: controller,
    onAnswerChanged: (text) =>
        ref.read(recallSessionProvider(deckId).notifier).updateAnswer(text),
    onReveal: () =>
        ref.read(recallSessionProvider(deckId).notifier).revealAnswer(),
    onEditCard: () {
      final card = state.currentCard;

      if (card == null) {
        return;
      }

      unawaited(context.push(CardEditScreen.routeLocation(deckId, card.id)));
    },
    onMarkMissed: () =>
        ref.read(recallSessionProvider(deckId).notifier).markMissed(),
    onRateSelf: (rating) =>
        ref.read(recallSessionProvider(deckId).notifier).rateSelf(rating),
  );
}

List<StudyMistakeItem> _recallMistakes(RecallState state) {
  final cardIds = state.results
      .where((result) => result.rating != SelfRating.gotIt)
      .map((result) => result.cardId)
      .toSet();
  return state.cards
      .where((card) => cardIds.contains(card.id))
      .map((card) => (front: card.front, back: card.back))
      .toList(growable: false);
}
