import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class StudyPlaceholderView extends StatelessWidget {
  const StudyPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) => EmptyStateView(
    icon: Icons.play_circle_outline,
    title: context.l10n.studyTitle,
    subtitle: context.l10n.studySubtitle,
  );
}
