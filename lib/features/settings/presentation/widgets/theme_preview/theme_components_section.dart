import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/inputs/app_text_field.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';
import 'package:memox/shared/widgets/lists/app_list_tile.dart';

class ThemeComponentsSection extends StatefulWidget {
  const ThemeComponentsSection({super.key});

  @override
  State<ThemeComponentsSection> createState() => _ThemeComponentsSectionState();
}

class _ThemeComponentsSectionState extends State<ThemeComponentsSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.themeComponentsTitle, style: context.textTheme.titleMedium),
          const Gap.lg(),
          AppCard(
            padding: EdgeInsets.zero,
            child: AppListTile(
              title: l10n.themeCardTitle,
              subtitle: l10n.themeCardSubtitle,
              leading: const CircleAvatar(child: Icon(Icons.style_outlined)),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const Gap.lg(),
          AppTextField(
            controller: _controller,
            label: l10n.themeInputLabel,
            hint: l10n.themeInputHint,
            prefixIcon: const Icon(Icons.search_outlined),
          ),
          const Gap.lg(),
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              PrimaryButton(
                label: l10n.themePrimaryAction,
                onPressed: () {},
                fullWidth: false,
              ),
              SecondaryButton(
                label: l10n.themeSecondaryAction,
                onPressed: () {},
                fullWidth: false,
              ),
              Chip(label: Text(l10n.themeAssistChip)),
              FilterChip(
                label: Text(l10n.themeFilterChip),
                selected: true,
                onSelected: (_) {},
              ),
            ],
          ),
          const Gap.lg(),
          const LinearProgressIndicator(
            value: 0.65,
            minHeight: SizeTokens.progressBarHeight,
          ),
        ],
      ),
    );
  }
}
