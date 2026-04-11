import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/presentation/widgets/study_mode_sheet.dart';
import 'package:memox/features/study/domain/usecases/build_study_deck_recommendation.dart';
import 'package:memox/features/study/presentation/screens/study_screen.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/chips/mode_chip.dart';

class StudyRecommendationCard extends StatelessWidget {
  const StudyRecommendationCard({required this.recommendation, super.key});

  final StudyDeckRecommendation recommendation;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SessionTypeBadge(
          sessionType: recommendation.sessionType.label(context.l10n),
        ),
        const SizedBox(height: SpacingTokens.md),
        Text(recommendation.deck.name, style: context.textTheme.titleLarge),
        const SizedBox(height: SpacingTokens.xs),
        Text(_subtitle(context), style: context.textTheme.bodySmall),
        const SizedBox(height: SpacingTokens.lg),
        _RecommendedModesPreview(
          modePlan: recommendation.modePlan,
          primaryMode: recommendation.primaryMode,
        ),
        const SizedBox(height: SpacingTokens.lg),
        PrimaryButton(
          label: context.l10n.studyStartRecommendedAction(
            recommendation.primaryMode.label(context.l10n),
            recommendation.deck.name,
          ),
          onPressed: () => context.push(
            StudyScreen.routeLocation(
              recommendation.deck.id,
              recommendation.primaryMode.name,
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        SecondaryButton(
          label: context.l10n.chooseStudyModeButton,
          onPressed: () => _chooseMode(context),
        ),
      ],
    ),
  );

  Future<void> _chooseMode(BuildContext context) async {
    final mode = await showStudyModeSheet(context);

    if (mode == null || !context.mounted) {
      return;
    }

    await context.push(
      StudyScreen.routeLocation(recommendation.deck.id, mode.name),
    );
  }

  String _subtitle(BuildContext context) {
    if (recommendation.dueCards > 0) {
      return context.l10n.studyDueCardsAction(recommendation.dueCards);
    }

    return context.l10n.studyDeckSessionSummary(
      recommendation.sessionType.label(context.l10n),
      recommendation.primaryMode.label(context.l10n),
    );
  }
}

class _SessionTypeBadge extends StatelessWidget {
  const _SessionTypeBadge({required this.sessionType});

  final String sessionType;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: OpacityTokens.hover),
        borderRadius: BorderRadius.circular(RadiusTokens.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.xs,
        ),
        child: Text(
          sessionType,
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colors.primary,
          ),
        ),
      ),
    ),
  );
}

class _RecommendedModesPreview extends StatelessWidget {
  const _RecommendedModesPreview({
    required this.modePlan,
    required this.primaryMode,
  });

  final List<StudyMode> modePlan;
  final StudyMode primaryMode;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.studyRecommendedModesLabel,
        style: context.textTheme.labelLarge?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: SpacingTokens.sm),
      Wrap(
        spacing: SpacingTokens.sm,
        runSpacing: SpacingTokens.sm,
        children: modePlan
            .map(
              (mode) => ModeChip(mode: mode, isSelected: mode == primaryMode),
            )
            .toList(growable: false),
      ),
    ],
  );
}
