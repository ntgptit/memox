import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/lists/app_list_tile.dart';

class ChoiceOption<T> {
  const ChoiceOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
  });

  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;
}

class ChoiceBottomSheet<T> extends StatelessWidget {
  const ChoiceBottomSheet({
    required this.title,
    required this.options,
    super.key,
  });

  final String title;
  final List<ChoiceOption<T>> options;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: SizeTokens.bottomSheetHandleWidth,
            height: SizeTokens.bottomSheetHandle,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(RadiusTokens.full),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: SpacingTokens.lg),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: context.screenHeight * 0.6),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: options.length,
              separatorBuilder: (_, _) => const SizedBox.shrink(),
              itemBuilder: (context, index) {
                final option = options[index];

                return AppListTile(
                  title: option.title,
                  subtitle: option.subtitle,
                  leading: option.icon == null ? null : Icon(option.icon),
                  variant: AppListTileVariant.sheet,
                  onTap: () => Navigator.of(context).pop(option.value),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Future<T?> showChoiceBottomSheet<T>(
  BuildContext context, {
  required String title,
  required List<ChoiceOption<T>> options,
}) => context.showAppBottomSheet<T>(
  ChoiceBottomSheet<T>(title: title, options: options),
);
