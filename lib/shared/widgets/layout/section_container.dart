import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';

class SectionContainer extends StatelessWidget {
  const SectionContainer({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: context.appTextStyles.sectionLabel,
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextLinkButton(label: actionLabel!, onTap: onAction),
        ],
      ),
      const SizedBox(height: SpacingTokens.md),
      child,
    ],
  );
}
