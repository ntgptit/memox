import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/statistics/domain/entities/difficult_card.dart';
import 'package:memox/features/study/presentation/screens/study_screen.dart';
import 'package:memox/shared/widgets/dialogs/choice_bottom_sheet.dart';

const List<StudyMode> practiceStudyModes = <StudyMode>[
  StudyMode.match,
  StudyMode.guess,
  StudyMode.recall,
  StudyMode.fill,
];

Future<void> showStatisticsPracticeFlow(
  BuildContext context,
  List<DifficultCard> cards,
) async {
  if (cards.isEmpty) {
    return;
  }

  final deckId = await _selectDeck(context, cards);

  if (deckId == null || !context.mounted) {
    return;
  }

  final mode = await _selectMode(context);

  if (mode == null || !context.mounted) {
    return;
  }

  await context.push(StudyScreen.routeLocation(deckId, mode.name));
}

Future<int?> _selectDeck(
  BuildContext context,
  List<DifficultCard> cards,
) async {
  final grouped = <int, ({String name, int count})>{};

  for (final item in cards) {
    final current = grouped[item.card.deckId];
    grouped[item.card.deckId] = (
      name: item.deckName,
      count: (current?.count ?? 0) + 1,
    );
  }

  if (grouped.length == 1) {
    return grouped.keys.single;
  }

  return showChoiceBottomSheet<int>(
    context,
    title: context.l10n.statisticsPracticeDeckTitle,
    options: grouped.entries
        .map(
          (entry) => ChoiceOption<int>(
            value: entry.key,
            title: entry.value.name,
            subtitle: context.l10n.statisticsPracticeDeckSubtitle(
              entry.value.count,
            ),
          ),
        )
        .toList(),
  );
}

Future<StudyMode?> _selectMode(BuildContext context) =>
    showChoiceBottomSheet<StudyMode>(
      context,
      title: context.l10n.studyModeSheetTitle,
      options: practiceStudyModes
          .map(
            (mode) => ChoiceOption<StudyMode>(
              value: mode,
              title: mode.label(context.l10n),
              subtitle: _modeDescription(context, mode),
            ),
          )
          .toList(),
    );

String _modeDescription(BuildContext context, StudyMode mode) => switch (mode) {
  StudyMode.match => context.l10n.modeMatchDescription,
  StudyMode.guess => context.l10n.modeGuessDescription,
  StudyMode.recall => context.l10n.modeRecallDescription,
  StudyMode.fill => context.l10n.modeFillDescription,
  StudyMode.review => context.l10n.modeReviewDescription,
};
