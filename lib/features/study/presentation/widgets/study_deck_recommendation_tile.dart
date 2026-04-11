import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/decks/presentation/widgets/study_mode_sheet.dart';
import 'package:memox/features/study/domain/usecases/build_study_deck_recommendation.dart';
import 'package:memox/features/study/presentation/screens/study_screen.dart';
import 'package:memox/shared/widgets/lists/app_list_tile.dart';

class StudyDeckRecommendationTile extends StatelessWidget {
  const StudyDeckRecommendationTile({
    required this.recommendation,
    required this.showDivider,
    super.key,
  });

  final StudyDeckRecommendation recommendation;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => AppListTile(
    title: recommendation.deck.name,
    subtitle: context.l10n.studyDeckSessionSummary(
      recommendation.sessionType.label(context.l10n),
      recommendation.primaryMode.label(context.l10n),
    ),
    leading: Text(recommendation.primaryMode.emoji),
    trailing: const Icon(Icons.chevron_right),
    showDivider: showDivider,
    onTap: () {
      unawaited(_chooseMode(context));
    },
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
}
