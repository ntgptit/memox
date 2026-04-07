import 'package:flutter/material.dart';
import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/lists/app_list_tile.dart';

class StudyModeSheet extends StatelessWidget {
  const StudyModeSheet({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.studyModeSheetTitle,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: SpacingTokens.md),
          ...StudyMode.values.map(
            (mode) => AppListTile(
              variant: AppListTileVariant.sheet,
              title: mode.label(context.l10n),
              subtitle: _description(context, mode),
              leading: _EmojiBubble(emoji: mode.emoji),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pop(mode),
            ),
          ),
        ],
      ),
    ),
  );

  String _description(BuildContext context, StudyMode mode) => switch (mode) {
    StudyMode.review => context.l10n.modeReviewDescription,
    StudyMode.match => context.l10n.modeMatchDescription,
    StudyMode.guess => context.l10n.modeGuessDescription,
    StudyMode.recall => context.l10n.modeRecallDescription,
    StudyMode.fill => context.l10n.modeFillDescription,
  };
}

class _EmojiBubble extends StatelessWidget {
  const _EmojiBubble({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerHighest,
      shape: BoxShape.circle,
    ),
    child: SizedBox.square(
      dimension: SizeTokens.avatarLg,
      child: Center(child: Text(emoji)),
    ),
  );
}

Future<StudyMode?> showStudyModeSheet(BuildContext context) =>
    context.showAppBottomSheet<StudyMode>(const StudyModeSheet());
