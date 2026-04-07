import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/presentation/providers/settings_provider.dart';
import 'package:memox/features/settings/presentation/widgets/settings_group_card.dart';
import 'package:memox/features/settings/presentation/widgets/settings_language_row.dart';
import 'package:memox/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/inputs/color_picker.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class SettingsAppearanceSection extends ConsumerWidget {
  const SettingsAppearanceSection({required this.settings, super.key});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SettingsSectionHeader(label: context.l10n.settingsAppearanceSection),
      const Gap.lg(),
      SettingsGroupCard(
        children: [
          _AppearanceBlock(
            title: context.l10n.settingsThemePreferenceTitle,
            child: _ThemeModeChooser(
              settings: settings,
              onThemeModeChanged: (value) =>
                  ref.read(settingsProvider.notifier).updateThemeMode(value),
            ),
          ),
          SettingsLanguageRow(settings: settings),
        ],
      ),
      const Gap.md(),
      SettingsGroupCard(
        children: [
          _AppearanceBlock(
            title: context.l10n.settingsAppColorTitle,
            child: ColorPicker(
              selectedColor: settings.seedColor,
              onChanged: (color) => ref
                  .read(settingsProvider.notifier)
                  .updateSeedColor(color.toARGB32()),
            ),
          ),
        ],
      ),
    ],
  );
}

class _AppearanceBlock extends StatelessWidget {
  const _AppearanceBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(SpacingTokens.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.titleMedium),
        const Gap.md(),
        child,
      ],
    ),
  );
}

class _ThemeModeChooser extends StatelessWidget {
  const _ThemeModeChooser({
    required this.settings,
    required this.onThemeModeChanged,
  });

  final AppSettings settings;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cardWidth = context.isCompact
          ? (constraints.maxWidth - SpacingTokens.sm) / 2
          : (constraints.maxWidth - (SpacingTokens.sm * 2)) / 3;

      return Wrap(
        spacing: SpacingTokens.sm,
        runSpacing: SpacingTokens.sm,
        children: [
          SizedBox(
            width: cardWidth,
            child: _ThemeModeCard(
              icon: Icons.brightness_auto_outlined,
              isSelected: settings.themeMode == ThemeMode.system,
              label: context.l10n.themeModeSystem,
              onTap: () => onThemeModeChanged(ThemeMode.system),
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: _ThemeModeCard(
              icon: Icons.light_mode_outlined,
              isSelected: settings.themeMode == ThemeMode.light,
              label: context.l10n.themeModeLight,
              onTap: () => onThemeModeChanged(ThemeMode.light),
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: _ThemeModeCard(
              icon: Icons.dark_mode_outlined,
              isSelected: settings.themeMode == ThemeMode.dark,
              label: context.l10n.themeModeDark,
              onTap: () => onThemeModeChanged(ThemeMode.dark),
            ),
          ),
        ],
      );
    },
  );
}

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? context.colors.primary
        : context.colors.outline.withValues(alpha: OpacityTokens.borderSubtle);

    return AppCard(
      onTap: onTap,
      borderColor: borderColor,
      backgroundColor: isSelected
          ? context.colors.primary.withValues(alpha: OpacityTokens.focus)
          : null,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.lg,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: SizeTokens.iconMd),
            const Gap.sm(),
            Text(
              label,
              textAlign: TextAlign.center,
              style: context.textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
