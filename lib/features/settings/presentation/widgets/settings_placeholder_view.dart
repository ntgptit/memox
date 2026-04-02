import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class SettingsPlaceholderView extends StatelessWidget {
  const SettingsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) => EmptyStateView(
    icon: Icons.settings_outlined,
    title: context.l10n.settingsTitle,
    subtitle: context.l10n.settingsSubtitle,
  );
}
