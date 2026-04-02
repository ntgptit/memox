import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class SettingsPlaceholderView extends StatelessWidget {
  const SettingsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) => const EmptyStateView(
    icon: Icons.settings_outlined,
    title: AppStrings.settingsTitle,
    subtitle: AppStrings.settingsSubtitle,
  );
}
