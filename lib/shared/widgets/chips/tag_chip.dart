import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class TagChip extends StatelessWidget {
  const TagChip({
    required this.label,
    this.onTap,
    this.onDelete,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => RawChip(
    label: Text(label, style: context.appTextStyles.tagText),
    onPressed: onTap,
    onDeleted: onDelete,
    side: BorderSide(color: context.colors.outline),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(RadiusTokens.chip),
    ),
    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}
