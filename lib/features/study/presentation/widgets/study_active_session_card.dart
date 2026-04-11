import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/decks/domain/entities/deck_entity.dart';
import 'package:memox/features/study/presentation/factories/study_mode_flow_factory.dart';
import 'package:memox/features/study/presentation/providers/active_study_session_store.dart';
import 'package:memox/features/study/presentation/providers/study_hub_provider.dart';
import 'package:memox/features/study/presentation/screens/study_screen.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class StudyActiveSessionCard extends ConsumerWidget {
  const StudyActiveSessionCard({required this.snapshot, this.deck, super.key});

  final ActiveStudySessionSnapshot snapshot;
  final DeckEntity? deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isActiveStudySessionResumable(snapshot)) {
      return const SizedBox.shrink();
    }

    final progress = _progress(snapshot);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.studyResumeTitle,
            style: context.textTheme.titleLarge,
          ),
          if (deck != null) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(deck!.name, style: context.textTheme.titleMedium),
          ],
          const SizedBox(height: SpacingTokens.sm),
          Text(
            context.l10n.studyResumeMessage(
              snapshot.mode.label(context.l10n),
              progress.completedCount,
              progress.totalCount,
            ),
            style: context.textTheme.bodySmall,
          ),
          const SizedBox(height: SpacingTokens.lg),
          PrimaryButton(
            label: context.l10n.studyResumeAction,
            onPressed: () => context.push(
              StudyScreen.routeLocation(snapshot.deckId, snapshot.mode.name),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          SecondaryButton(
            label: context.l10n.studyStartOverAction,
            onPressed: () => _startOver(ref),
          ),
        ],
      ),
    );
  }

  Future<void> _startOver(WidgetRef ref) async {
    final store = await ref.read(activeStudySessionStoreProvider.future);
    await store.clearIfMatches(deckId: snapshot.deckId, mode: snapshot.mode);
    studyModeFlowFactory
        .resolve(snapshot.mode)
        .invalidateSession(ref, snapshot.deckId);
    ref
      ..invalidate(activeStudySessionSnapshotProvider)
      ..invalidate(studyHubProvider);
  }
}

StudySnapshotProgress _progress(ActiveStudySessionSnapshot snapshot) =>
    studyModeFlowFactory.resolve(snapshot.mode).progressFromSnapshot(snapshot);
