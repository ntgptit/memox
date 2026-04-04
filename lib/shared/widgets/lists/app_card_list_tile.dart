import 'package:flutter/material.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class AppCardListTile extends StatelessWidget {
  const AppCardListTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.titleTrailing,
    this.trailing,
    this.supporting,
    this.onTap,
    this.onLongPress,
    this.borderColor,
    super.key,
  });

  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? titleTrailing;
  final Widget? trailing;
  final Widget? supporting;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    onLongPress: onLongPress,
    borderColor: borderColor,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            leading,
            const Gap.lg(),
            Expanded(
              child: _AppCardListTileHeader(
                title: title,
                subtitle: subtitle,
                titleTrailing: titleTrailing,
              ),
            ),
            if (trailing != null) ...[const Gap.md(), trailing!],
          ],
        ),
        if (supporting != null) ...[const Gap.md(), supporting!],
      ],
    ),
  );
}

class _AppCardListTileHeader extends StatelessWidget {
  const _AppCardListTileHeader({
    required this.title,
    required this.subtitle,
    required this.titleTrailing,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? titleTrailing;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(child: title),
          if (titleTrailing != null) ...[const Gap.sm(), titleTrailing!],
        ],
      ),
      if (subtitle != null) ...[const Gap.xs(), subtitle!],
    ],
  );
}
