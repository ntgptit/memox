import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/settings/presentation/widgets/settings_placeholder_view.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String routeName = 'settings';
  static const String routePath = '/settings';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.settingsTitle)),
    body: const SettingsPlaceholderView(),
  );
}
