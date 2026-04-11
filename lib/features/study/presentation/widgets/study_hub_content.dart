import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/presentation/providers/study_hub_provider.dart';
import 'package:memox/features/study/presentation/widgets/study_active_session_card.dart';
import 'package:memox/features/study/presentation/widgets/study_deck_picker_section.dart';
import 'package:memox/features/study/presentation/widgets/study_recommendation_card.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class StudyHubContent extends StatelessWidget {
  const StudyHubContent({required this.data, super.key});

  final StudyHubData data;

  @override
  Widget build(BuildContext context) {
    if (!data.hasRecommendations && data.activeSession == null) {
      return EmptyStateView(
        icon: Icons.play_circle_outline,
        title: context.l10n.studyTitle,
        subtitle: context.l10n.studySubtitle,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (data.activeSession != null)
            StudyActiveSessionCard(
              snapshot: data.activeSession!,
              deck: data.activeDeck,
            ),
          if (data.activeSession != null && data.recommended != null)
            const SizedBox(height: SpacingTokens.lg),
          if (data.recommended case final recommendation?)
            StudyRecommendationCard(recommendation: recommendation),
          if (data.remainingRecommendations.isNotEmpty)
            const SizedBox(height: SpacingTokens.xxl),
          if (data.remainingRecommendations.isNotEmpty)
            StudyDeckPickerSection(
              recommendations: data.remainingRecommendations,
            ),
        ],
      ),
    );
  }
}
