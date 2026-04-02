import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class FoldersPlaceholderView extends StatelessWidget {
  const FoldersPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) => const EmptyStateView(
    icon: Icons.folder_outlined,
    title: AppStrings.foldersTitle,
    subtitle: AppStrings.foldersSubtitle,
  );
}
