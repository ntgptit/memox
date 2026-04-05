import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final tile = Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: subtitle == null
                ? SizeTokens.listItemHeight
                : SizeTokens.listItemTall,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
            child: Row(
              children: [
                if (leading != null) ...[
                  SizedBox.square(
                    dimension: SizeTokens.avatarLg,
                    child: Center(child: leading),
                  ),
                  const SizedBox(width: SpacingTokens.lg),
                ],
                Expanded(
                  child: _TitleBlock(title: title, subtitle: subtitle),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: SpacingTokens.md),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (!showDivider) {
      return tile;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        Divider(
          height: SizeTokens.dividerThickness,
          indent: leading == null ? 0 : SpacingTokens.dividerIndent,
          color: context.colors.outline.withValues(
            alpha: OpacityTokens.divider,
          ),
        ),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.title, required this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: context.textTheme.titleMedium),
      if (subtitle != null) Text(subtitle!, style: context.textTheme.bodySmall),
    ],
  );
}
