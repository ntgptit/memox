import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class ColorPicker extends StatelessWidget {
  const ColorPicker({
    required this.selectedColor,
    required this.onChanged,
    this.colors = ColorTokens.availableSeeds,
    super.key,
  });

  final Color selectedColor;
  final ValueChanged<Color> onChanged;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: SpacingTokens.chipGap,
    runSpacing: SpacingTokens.chipGap,
    children: colors
        .map((color) => _ColorChoice(
              color: color,
              isSelected: color == selectedColor,
              onTap: () => onChanged(color),
            ))
        .toList(),
  );
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? context.colors.surface
        : context.colors.onSurface;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox.square(
        dimension: SizeTokens.avatarLg,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: isSelected
              ? Icon(Icons.check_rounded, color: iconColor)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
