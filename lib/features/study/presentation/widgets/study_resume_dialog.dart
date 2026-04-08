import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/dialogs/app_dialog.dart';

class StudyResumeDialog extends StatelessWidget {
  const StudyResumeDialog({
    required this.modeLabel,
    required this.completedCount,
    required this.totalCount,
    super.key,
  });

  final String modeLabel;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) => AppDialog(
    title: Text(context.l10n.studyResumeTitle),
    content: Text(
      context.l10n.studyResumeMessage(modeLabel, completedCount, totalCount),
    ),
    actions: [
      SecondaryButton(
        label: context.l10n.studyResumeAction,
        onPressed: () => Navigator.of(context).pop(false),
        fullWidth: false,
      ),
      PrimaryButton(
        label: context.l10n.studyStartOverAction,
        onPressed: () => Navigator.of(context).pop(true),
        fullWidth: false,
      ),
    ],
  );
}
