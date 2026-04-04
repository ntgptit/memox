import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';

class SettingsGroupCard extends StatelessWidget {
  const SettingsGroupCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Column(children: _buildChildren(context)),
  );

  List<Widget> _buildChildren(BuildContext context) {
    final widgets = <Widget>[];

    for (var index = 0; index < children.length; index++) {
      widgets.add(children[index]);

      if (index == children.length - 1) {
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
          child: Divider(
            height: SizeTokens.dividerThickness,
            thickness: SizeTokens.dividerThickness,
            color: context.colors.outline.withValues(
              alpha: OpacityTokens.divider,
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
