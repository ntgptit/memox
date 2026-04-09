import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class TagChip extends StatelessWidget {
  const TagChip({required this.label, this.onTap, this.onDelete, super.key});

  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => RawChip(
    label: Text(label, style: context.appTextStyles.tagText),
    onPressed: onTap,
    onDeleted: onDelete,
    backgroundColor: context.colors.surfaceContainerLowest,
    side: BorderSide(
      color: context.colors.outlineVariant.withValues(
        alpha: OpacityTokens.borderSubtle,
      ),
    ),
    deleteIconColor: context.colors.onSurfaceVariant,
    shape: StadiumBorder(
      side: BorderSide(
        color: context.colors.outlineVariant.withValues(
          alpha: OpacityTokens.borderSubtle,
        ),
      ),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.sm,
      vertical: SpacingTokens.xs,
    ),
    labelPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}
