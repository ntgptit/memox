import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/responsive/responsive_padding.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/match/match_engine.dart';
import 'package:memox/features/study/presentation/providers/match_provider.dart';
import 'package:memox/features/study/presentation/widgets/match_item_board.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class MatchRoundView extends StatelessWidget {
  const MatchRoundView({
    required this.state,
    required this.onSelect,
    super.key,
  });

  final MatchState state;
  final ValueChanged<({String id, String text, MatchItemType type})> onSelect;

  @override
  Widget build(BuildContext context) {
    if (state.game.correctPairs.isEmpty) {
      return EmptyStateView(
        icon: Icons.style_outlined,
        title: context.l10n.cardsEmptyTitle,
        subtitle: context.l10n.matchEmptySubtitle,
      );
    }

    return Padding(
      padding: ResponsivePadding.horizontal(
        context,
      ).add(const EdgeInsets.symmetric(vertical: SpacingTokens.lg)),
      child: MatchItemBoard(state: state, onSelect: onSelect),
    );
  }
}
