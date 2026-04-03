import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/features/settings/presentation/widgets/settings_content_view.dart';
import 'package:memox/shared/widgets/layout/app_scaffold.dart';
import 'package:memox/shared/widgets/navigation/app_root_bottom_nav.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String routeName = 'settings';
  static const String routePath = '/settings';

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: Text(context.l10n.settingsTitle)),
    bottomNavigationBar: const AppRootBottomNav(currentIndex: 3),
    body: const SettingsContentView(),
  );
}
