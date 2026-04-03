import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class TopBarActionRow extends StatelessWidget {
  const TopBarActionRow({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      right: context.screenType.screenPadding - SpacingTokens.sm,
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: children),
  );
}
