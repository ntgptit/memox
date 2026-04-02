import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class StudyPlaceholderView extends StatelessWidget {
  const StudyPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) => const EmptyStateView(
    icon: Icons.play_circle_outline,
    title: AppStrings.studyTitle,
    subtitle: AppStrings.studySubtitle,
  );
}
