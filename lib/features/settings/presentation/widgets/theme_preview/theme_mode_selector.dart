import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final themeMode = settingsAsync.maybeWhen(
      data: (settings) => settings.themeMode,
      orElse: () => ThemeMode.system,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.themeModeTitle,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: SpacingTokens.lg),
          SegmentedButton<ThemeMode>(
            segments: <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text(context.l10n.themeModeSystem),
                icon: const Icon(Icons.brightness_auto_outlined),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text(context.l10n.themeModeLight),
                icon: const Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text(context.l10n.themeModeDark),
                icon: const Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: <ThemeMode>{themeMode},
            onSelectionChanged: (selection) {
              unawaited(
                ref
                    .read(settingsProvider.notifier)
                    .updateThemeMode(selection.first),
              );
            },
          ),
        ],
      ),
    );
  }
}
