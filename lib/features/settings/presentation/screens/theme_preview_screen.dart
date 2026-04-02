import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/settings/presentation/widgets/theme_preview/theme_components_section.dart';
import 'package:memox/features/settings/presentation/widgets/theme_preview/theme_mode_selector.dart';
import 'package:memox/features/settings/presentation/widgets/theme_preview/theme_preview_navigation_bar.dart';
import 'package:memox/features/settings/presentation/widgets/theme_preview/theme_typography_section.dart';

class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  static const String routeName = 'theme-preview';
  static const String routePath = '/theme-preview';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.themePreviewTitle)),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () {},
      icon: const Icon(Icons.add_rounded),
      label: const Text(AppStrings.themeFabLabel),
    ),
    bottomNavigationBar: const ThemePreviewNavigationBar(),
    body: ListView(
      padding: const EdgeInsets.all(SpacingTokens.xl),
      children: const [
        ThemeModeSelector(),
        SizedBox(height: SpacingTokens.xl),
        ThemeTypographySection(),
        SizedBox(height: SpacingTokens.xl),
        ThemeComponentsSection(),
      ],
    ),
  );
}
