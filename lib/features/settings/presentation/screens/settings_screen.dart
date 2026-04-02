import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:memox/features/settings/presentation/widgets/settings_placeholder_view.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String routeName = 'settings';
  static const String routePath = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(settingsScreenTitleProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const SettingsPlaceholderView(),
    );
  }
}
