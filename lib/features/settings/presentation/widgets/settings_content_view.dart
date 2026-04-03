import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/providers/service_providers.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/settings/presentation/widgets/settings_database_card.dart';
import 'package:memox/features/settings/presentation/widgets/theme_preview/theme_mode_selector.dart';

class SettingsContentView extends ConsumerWidget {
  const SettingsContentView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExportSupported = ref
        .watch(databaseExportServiceProvider)
        .isSupported;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
      children: [
        const ThemeModeSelector(),
        if (isExportSupported) ...const [
          SizedBox(height: SpacingTokens.xl),
          SettingsDatabaseCard(),
        ],
      ],
    );
  }
}
