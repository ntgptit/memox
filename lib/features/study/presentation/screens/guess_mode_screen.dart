import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/presentation/providers/guess_provider.dart';
import 'package:memox/features/study/presentation/widgets/guess_round_view.dart';
import 'package:memox/features/study/presentation/widgets/study_mistakes_panel.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';
import 'package:memox/shared/widgets/feedback/session_complete_view.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/navigation/study_top_bar.dart';

class GuessModeScreen extends ConsumerWidget {
  const GuessModeScreen({required this.deckId, super.key});

  final int deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guessSessionProvider(deckId));
    return AppAsyncBuilder<GuessState>(
      value: state,
      onRetry: () {
        unawaited(
          ref.read(guessSessionProvider(deckId).notifier).startSession(),
        );
      },
      onData: (data) => AppScaffold(
        appBar: StudyTopBar(
          title: context.l10n.modeGuess,
          current: data.isComplete ? data.totalCards : data.displayIndex,
          total: data.totalCards,
          streak: data.streak,
          showProgress: data.cards.isNotEmpty && !data.isComplete,
          onClose: () => unawaited(_handleClose(context)),
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
  GuessState data,
) {
  if (data.cards.isEmpty) {
    return EmptyStateView(
      icon: Icons.quiz_outlined,
      title: context.l10n.modeGuess,
      subtitle: context.l10n.guessEmptySubtitle,
    );
  }

  if (data.isComplete) {
    return _buildCompletionView(
      context,
      data,
      onDone: () => context.pop<void>(),
      onPlayAgain: () =>
          ref.read(guessSessionProvider(deckId).notifier).startSession(),
    );
  }

  return GuessRoundView(
    state: data,
    onSelect: (index) =>
        ref.read(guessSessionProvider(deckId).notifier).selectOption(index),
    onSkip: () =>
        ref.read(guessSessionProvider(deckId).notifier).skipQuestion(),
    onContinue: () =>
        ref.read(guessSessionProvider(deckId).notifier).nextQuestion(),
  );
}

Widget _buildCompletionView(
  BuildContext context,
  GuessState state, {
  required VoidCallback onDone,
  required VoidCallback onPlayAgain,
}) {
  final difficultCards = _guessMistakes(state);
  return SessionCompleteView(
    title: context.l10n.guessCompleteTitle,
    stats: [
      SessionStat(
        label: context.l10n.guessCorrectLabel,
        icon: Icons.check_circle_outline,
        value: '${state.correctCount}/${state.totalCards}',
      ),
      SessionStat(
        label: context.l10n.guessAccuracyLabel,
        icon: Icons.track_changes_outlined,
        value: '${state.accuracy}%',
      ),
      SessionStat(
        label: context.l10n.guessBestStreakLabel,
        icon: Icons.local_fire_department_outlined,
        value: '${state.bestStreak}',
        valueColor: context.customColors.mastery,
      ),
    ],
    extraContent: Column(
      children: [
        Text(
          context.l10n.guessCompletionSummary(
            state.correctCount,
            state.totalCards,
            state.accuracy,
          ),
          style: context.appTextStyles.statNumberSm,
          textAlign: TextAlign.center,
        ),
        if (state.skippedCount > 0) ...[
          const SizedBox(height: SpacingTokens.sm),
          Text(
            context.l10n.guessSkippedSummary(state.skippedCount),
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
        const SizedBox(height: SpacingTokens.lg),
        SecondaryButton(
          label: context.l10n.guessPlayAgainAction,
          onPressed: onPlayAgain,
        ),
      ],
    ),
    primaryAction: SessionAction(label: context.l10n.doneAction, onTap: onDone),
  );
}

List<StudyMistakeItem> _guessMistakes(GuessState state) {
  final cardIds = state.results
      .where((result) => !result.isCorrect)
      .map((result) => result.cardId)
      .toSet();
  return state.cards
      .where((card) => cardIds.contains(card.id))
      .map((card) => (front: card.front, back: card.back))
      .toList(growable: false);
}
