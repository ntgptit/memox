import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/cards/presentation/screens/card_edit_screen.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/match_provider.dart';
import 'package:memox/features/study/presentation/widgets/match_elapsed_timer_text.dart';
import 'package:memox/features/study/presentation/widgets/match_round_view.dart';
import 'package:memox/features/study/presentation/widgets/match_star_rating.dart';
import 'package:memox/features/study/presentation/widgets/study_mistakes_panel.dart';
import 'package:memox/features/study/presentation/widgets/study_next_deck_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/feedback/session_complete_view.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/navigation/study_top_bar.dart';

class MatchModeScreen extends ConsumerWidget {
  const MatchModeScreen({required this.deckId, super.key});

  final int deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchSessionProvider(deckId));
    return AppAsyncBuilder<MatchState>(
      value: state,
      onRetry: () {
        unawaited(ref.read(matchSessionProvider(deckId).notifier).startGame());
      },
      onData: (data) => AppScaffold(
        appBar: StudyTopBar(
          title: context.l10n.modeMatch,
          current: data.matchedCount,
          total: data.totalPairs,
          subtitle: context.l10n.matchPairsLeft(data.pairsLeft),
          trailing: data.isComplete
              ? Text(
                  _elapsedLabel(data.startTime),
                  style: context.appTextStyles.progressCount.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                )
              : MatchElapsedTimerText(startTime: data.startTime),
          showProgress: false,
          onClose: () => unawaited(_handleClose(context, ref)),
        ),
        applyBottomPadding: false,
        applyHorizontalPadding: false,
        body: data.isComplete
            ? _buildCompletionView(
                context,
                data,
                currentDeckId: deckId,
                onDone: () => Navigator.of(context).pop(),
                onPlayAgain: () =>
                    ref.read(matchSessionProvider(deckId).notifier).startGame(),
              )
            : MatchRoundView(
                state: data,
                onSelect: (item) => ref
                    .read(matchSessionProvider(deckId).notifier)
                    .selectItem(item),
              ),
      ),
    );
  }

  Future<void> _handleClose(BuildContext context, WidgetRef ref) async {
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
    await store.clearIfMatches(deckId: deckId, mode: StudyMode.match);

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop();
  }
}

Widget _buildCompletionView(
  BuildContext context,
  MatchState state, {
  required int currentDeckId,
  required VoidCallback onDone,
  required VoidCallback onPlayAgain,
}) {
  final starCount = _starCount(state.mistakes);
  final difficultCards = _matchMistakes(state);
  return SessionCompleteView(
    title: context.l10n.matchCompleteTitle,
    stats: [
      SessionStat(
        label: context.l10n.matchTimeLabel,
        icon: Icons.schedule_outlined,
        value: _elapsedLabel(state.startTime),
      ),
      SessionStat(
        label: context.l10n.matchMistakesLabel,
        icon: Icons.close_outlined,
        value: '${state.mistakes}',
      ),
      SessionStat(
        label: context.l10n.matchStarsLabel,
        icon: Icons.grade_outlined,
        value: '$starCount/3',
        valueColor: context.customColors.warning,
      ),
    ],
    extraContent: Column(
      children: [
        MatchStarRating(starCount: starCount),
        if (difficultCards.isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.lg),
          StudyMistakesPanel(
            items: difficultCards,
            onTapItem: (item) => unawaited(
              context.push(
                CardEditScreen.routeLocation(currentDeckId, item.cardId),
              ),
            ),
          ),
        ],
        const SizedBox(height: SpacingTokens.lg),
        StudyNextDeckButton(
          currentDeckId: currentDeckId,
          mode: StudyMode.match,
        ),
        const SizedBox(height: SpacingTokens.sm),
        SecondaryButton(
          label: context.l10n.matchPlayAgainAction,
          onPressed: onPlayAgain,
        ),
      ],
    ),
    primaryAction: SessionAction(label: context.l10n.doneAction, onTap: onDone),
  );
}

String _elapsedLabel(DateTime startTime) {
  final elapsed = DateTime.now().difference(startTime);
  final minutes = elapsed.inMinutes;
  final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

int _starCount(int mistakes) {
  if (mistakes == 0) {
    return 3;
  }

  if (mistakes <= 2) {
    return 2;
  }

  return 1;
}

List<StudyMistakeItem> _matchMistakes(MatchState state) {
  if (state.attemptCounts.isEmpty) {
    return const <StudyMistakeItem>[];
  }

  final termsById = {for (final item in state.game.terms) item.id: item.text};
  final definitionsById = {
    for (final item in state.game.definitions) item.id: item.text,
  };
  return state.attemptCounts.entries
      .map(
        (entry) => (
          cardId: int.tryParse(entry.key.replaceFirst('term-', '')) ?? 0,
          front: termsById[entry.key] ?? entry.key,
          back: definitionsById[state.game.correctPairs[entry.key]] ?? '',
        ),
      )
      .toList(growable: false);
}
