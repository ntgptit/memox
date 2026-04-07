import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:memox/features/settings/presentation/widgets/settings_appearance_section.dart';
import 'package:memox/features/settings/presentation/widgets/settings_backup_section.dart';
import 'package:memox/features/settings/presentation/widgets/settings_data_section.dart';
import 'package:memox/features/settings/presentation/widgets/settings_notifications_section.dart';
import 'package:memox/features/settings/presentation/widgets/settings_studying_section.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/feedback/app_refresh_indicator.dart';

class SettingsContentView extends ConsumerWidget {
  const SettingsContentView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return AppAsyncBuilder<AppSettings>(
      value: settingsAsync,
      onRetry: () {
        unawaited(_refreshSettings(ref));
      },
      onData: (settings) => AppRefreshIndicator(
        onRefresh: () => _refreshSettings(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: SpacingTokens.xl,
            bottom: SpacingTokens.xxxl,
          ),
          children: [
            SettingsAppearanceSection(settings: settings),
            const SizedBox(height: SpacingTokens.xl),
            SettingsStudyingSection(settings: settings),
            const SizedBox(height: SpacingTokens.xl),
            SettingsNotificationsSection(settings: settings),
            const SizedBox(height: SpacingTokens.xl),
            const SettingsBackupSection(),
            const SizedBox(height: SpacingTokens.xl),
            const SettingsDataSection(),
          ],
        ),
      ),
    );
  }
}

Future<void> _refreshSettings(WidgetRef ref) async {
  ref.invalidate(settingsProvider);
  await ref.read(settingsProvider.future);
}
