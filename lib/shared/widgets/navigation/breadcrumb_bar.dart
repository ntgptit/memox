import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/shared/widgets/buttons/inline_text_link_button.dart';

class BreadcrumbSegment {
  const BreadcrumbSegment({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;
}

class BreadcrumbBar extends StatelessWidget {
  const BreadcrumbBar({required this.segments, super.key});

  final List<BreadcrumbSegment> segments;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: List<Widget>.generate(segments.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
            child: Icon(
              Icons.chevron_right,
              size: SizeTokens.iconSm,
              color: context.colors.onSurfaceVariant,
            ),
          );
        }

        final segment = segments[index ~/ 2];
        final isCurrent = index == segments.length * 2 - 2;
        final style = context.appTextStyles.breadcrumb.copyWith(
          color: isCurrent
              ? context.colors.onSurface
              : context.colors.onSurfaceVariant,
          fontWeight: isCurrent
              ? TypographyTokens.medium
              : TypographyTokens.regular,
        );

        return Align(
          alignment: Alignment.centerLeft,
          child: InlineTextLinkButton(
            label: segment.label,
            onTap: isCurrent ? null : segment.onTap,
            color: style.color,
            activeColor: context.colors.primary,
            textStyle: style,
          ),
        );
      }),
    ),
  );
}
