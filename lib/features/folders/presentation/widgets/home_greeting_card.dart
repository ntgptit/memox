import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/folders/presentation/providers/folders_provider.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';

class HomeGreetingCard extends StatelessWidget {
  const HomeGreetingCard({
    required this.summary,
    required this.onReviewNow,
    super.key,
  });

  final AsyncValue<HomeDueSummary> summary;
  final ValueChanged<DeckEntity> onReviewNow;

  @override
  Widget build(BuildContext context) => AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.homeGreeting(
              _timeOfDayLabel(context),
              context.l10n.homeDefaultName,
            ),
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: SpacingTokens.sm),
          AppAsyncBuilder<HomeDueSummary>(
            value: summary,
            animate: false,
            onData: (data) =>
                _GreetingBody(data: data, onReviewNow: onReviewNow),
          ),
        ],
      ),
    );

  String _timeOfDayLabel(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return context.l10n.timeOfDayMorning;
    }

    if (hour < 18) {
      return context.l10n.timeOfDayAfternoon;
    }

    return context.l10n.timeOfDayEvening;
  }
}

class _GreetingBody extends StatelessWidget {
  const _GreetingBody({required this.data, required this.onReviewNow});

  final HomeDueSummary data;
  final ValueChanged<DeckEntity> onReviewNow;

  @override
  Widget build(BuildContext context) => Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.homeDueCards(data.dueCardCount),
            style: context.textTheme.bodyLarge,
          ),
        ),
        if (data.firstDueDeck case final dueDeck?)
          TextLinkButton(
            label: context.l10n.reviewNowAction,
            onTap: () => onReviewNow(dueDeck),
            showTrailingArrow: true,
          ),
      ],
    );
}
