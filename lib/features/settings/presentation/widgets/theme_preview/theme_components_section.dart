import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/buttons/secondary_button.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class ThemeComponentsSection extends StatelessWidget {
  const ThemeComponentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.themeComponentsTitle, style: context.textTheme.titleMedium),
          const SizedBox(height: SpacingTokens.lg),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.style_outlined)),
              title: Text(l10n.themeCardTitle),
              subtitle: Text(l10n.themeCardSubtitle),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          TextField(
            decoration: InputDecoration(
              labelText: l10n.themeInputLabel,
              hintText: l10n.themeInputHint,
              prefixIcon: const Icon(Icons.search_outlined),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
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
          const SizedBox(height: SpacingTokens.lg),
          const LinearProgressIndicator(
            value: 0.65,
            minHeight: SizeTokens.progressBarHeight,
          ),
        ],
      ),
    );
  }
}
