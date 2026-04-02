import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class ThemeComponentsSection extends StatelessWidget {
  const ThemeComponentsSection({super.key});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.themeComponentsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: SpacingTokens.lg),
          const Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.style_outlined)),
              title: Text(AppStrings.themeCardTitle),
              subtitle: Text(AppStrings.themeCardSubtitle),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          const TextField(
            decoration: InputDecoration(
              labelText: AppStrings.themeInputLabel,
              hintText: AppStrings.themeInputHint,
              prefixIcon: Icon(Icons.search_outlined),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text(AppStrings.themePrimaryAction),
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text(AppStrings.themeSecondaryAction),
              ),
              const Chip(label: Text(AppStrings.themeAssistChip)),
              FilterChip(
                label: const Text(AppStrings.themeFilterChip),
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
    ),
  );
}
