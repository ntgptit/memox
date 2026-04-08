import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/srs/srs_engine.dart';
import 'package:memox/features/study/presentation/providers/recall_provider.dart';
import 'package:memox/features/study/presentation/widgets/recall_prompt_card.dart';
import 'package:memox/features/study/presentation/widgets/recall_reveal_phase.dart';
import 'package:memox/features/study/presentation/widgets/recall_writing_area.dart';

const double _recallSwitchLift = 0.04;
const double _recallPromptMaxHeightFactor = 0.4;

class RecallRoundView extends StatelessWidget {
  const RecallRoundView({
    required this.state,
    required this.controller,
    required this.onAnswerChanged,
    required this.onReveal,
    required this.onEditCard,
    required this.onMarkMissed,
    required this.onRateSelf,
    super.key,
  });

  final RecallState state;
  final TextEditingController controller;
  final ValueChanged<String> onAnswerChanged;
  final VoidCallback onReveal;
  final VoidCallback onEditCard;
  final VoidCallback onMarkMissed;
  final ValueChanged<SelfRating> onRateSelf;

  @override
  Widget build(BuildContext context) {
    final card = state.currentCard;
    if (card == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        SpacingTokens.screenPadding,
        SpacingTokens.screenPadding,
        SpacingTokens.screenPadding,
        SpacingTokens.screenPadding + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * _recallPromptMaxHeightFactor,
              ),
              child: RecallPromptCard(key: ValueKey<int>(card.id), card: card),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Expanded(
              child: AnimatedSwitcher(
                duration: DurationTokens.contentSwitch,
                reverseDuration: DurationTokens.fast,
                transitionBuilder: _transitionBuilder,
                child: state.isRevealed
                    ? RecallRevealPhase(
                        key: ValueKey<String>('reveal-${card.id}'),
                        card: card,
                        state: state,
                        onEditCard: onEditCard,
                        onRateSelf: onRateSelf,
                      )
                    : SingleChildScrollView(
                        key: ValueKey<String>('write-${card.id}'),
                        child: RecallWritingArea(
                          controller: controller,
                          canReveal: state.canReveal,
                          onChanged: onAnswerChanged,
                          onMarkMissed: onMarkMissed,
                          onReveal: onReveal,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _transitionBuilder(Widget child, Animation<double> animation) =>
    FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, _recallSwitchLift),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
