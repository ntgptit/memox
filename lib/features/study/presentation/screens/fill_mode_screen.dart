import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/fill/fill_engine.dart';
import 'package:memox/features/study/presentation/providers/fill_provider.dart';
import 'package:memox/features/study/presentation/providers/study_engine_providers.dart';
import 'package:memox/features/study/presentation/widgets/fill_mistakes_panel.dart';
import 'package:memox/features/study/presentation/widgets/fill_round_view.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';
import 'package:memox/shared/widgets/feedback/session_complete_view.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/navigation/study_top_bar.dart';

class FillModeScreen extends ConsumerStatefulWidget {
  const FillModeScreen({required this.deckId, super.key});

  final int deckId;

  @override
  ConsumerState<FillModeScreen> createState() => _FillModeScreenState();
}

class _FillModeScreenState extends ConsumerState<FillModeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = fillSessionProvider(widget.deckId);
    ref.listen<AsyncValue<FillState>>(
      provider,
      (_, next) => _handleState(next),
    );
    return AppAsyncBuilder<FillState>(
      value: ref.watch(provider),
      onRetry: () {
        unawaited(
          ref.read(fillSessionProvider(widget.deckId).notifier).startSession(),
        );
      },
      onData: (state) => AppScaffold(
        appBar: StudyTopBar(
          title: context.l10n.modeFill,
          current: state.isComplete ? state.totalCards : state.displayIndex,
          total: state.totalCards,
          streak: state.streak,
          streakThreshold: 3,
          onClose: () => unawaited(_handleClose(context)),
        ),
        applyBottomPadding: false,
        applyHorizontalPadding: false,
        body: _buildBody(
          context,
          ref,
          widget.deckId,
          state,
          _controller,
          _focusNode,
        ),
      ),
    );
  }

  void _handleState(AsyncValue<FillState> next) {
    final state = next.asData?.value;

    if (state == null) {
      return;
    }

    _syncController(state.userInput);

    if (state.isComplete ||
        state.result == FillResult.close ||
        state.result == FillResult.correct) {
      _focusNode.unfocus();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
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

  void _syncController(String value) {
    if (_controller.text == value) {
      return;
    }

    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}

Widget _buildBody(
  BuildContext context,
  WidgetRef ref,
  int deckId,
  FillState state,
  TextEditingController controller,
  FocusNode focusNode,
) {
  if (state.cards.isEmpty) {
    return EmptyStateView(
      icon: Icons.edit_outlined,
      title: context.l10n.modeFill,
      subtitle: context.l10n.fillEmptySubtitle,
    );
  }

  if (state.isComplete) {
    final accuracy = state.totalCards == 0
        ? 0
        : ((state.firstTryCorrectCount / state.totalCards) * 100).round();
    return SessionCompleteView(
      title: context.l10n.fillCompleteTitle(state.totalCards),
      stats: [
        SessionStat(
          label: context.l10n.fillCorrectFirstTryLabel,
          icon: Icons.check_circle_outline,
          value: '${state.firstTryCorrectCount} ($accuracy%)',
          valueColor: context.customColors.ratingGood,
        ),
        SessionStat(
          label: context.l10n.fillAcceptedCloseLabel,
          icon: Icons.spellcheck_outlined,
          value: '${state.acceptedCloseCount}',
          valueColor: context.customColors.ratingHard,
        ),
        SessionStat(
          label: context.l10n.fillRetryNeededLabel,
          icon: Icons.refresh_outlined,
          value: '${state.neededRetryCount}',
        ),
        SessionStat(
          label: context.l10n.fillLongestStreakLabel,
          icon: Icons.local_fire_department_outlined,
          value: '${state.bestStreak}',
          valueColor: context.customColors.mastery,
        ),
      ],
      extraContent: Column(
        children: [
          Text(
            context.l10n.fillCompletionSummary(
              state.firstTryCorrectCount,
              accuracy,
            ),
            style: context.appTextStyles.statNumberSm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.lg),
          FillMistakesPanel(cards: state.cards, results: state.results),
        ],
      ),
      primaryAction: SessionAction(
        label: context.l10n.doneAction,
        onTap: () => context.pop<void>(),
      ),
      secondaryAction: state.canPracticeMistakes
          ? SessionAction(
              label: context.l10n.fillPracticeMistakesAction,
              onTap: () => ref
                  .read(fillSessionProvider(deckId).notifier)
                  .practiceMistakes(),
            )
          : null,
    );
  }

  final isNumericAnswer = ref
      .read(fillEngineProvider)
      .isNumericAnswer(state.currentPrompt.correctAnswer);
  final missingExamples = state.cards
      .where((card) => card.example.trim().isEmpty)
      .length;
  return FillRoundView(
    state: state,
    controller: controller,
    focusNode: focusNode,
    isNumericAnswer: isNumericAnswer,
    warningText: missingExamples == 0
        ? null
        : context.l10n.fillExamplesRecommendedWarning(
            missingExamples,
            state.totalCards,
          ),
    onInputChanged: (text) =>
        ref.read(fillSessionProvider(deckId).notifier).updateInput(text),
    onSubmit: () =>
        ref.read(fillSessionProvider(deckId).notifier).submitAnswer(),
    onShowHint: () =>
        ref.read(fillSessionProvider(deckId).notifier).toggleHint(),
    onAcceptClose: () =>
        ref.read(fillSessionProvider(deckId).notifier).acceptClose(),
    onRejectClose: () =>
        ref.read(fillSessionProvider(deckId).notifier).rejectClose(),
    onSkip: () => ref.read(fillSessionProvider(deckId).notifier).skipCard(),
  );
}
