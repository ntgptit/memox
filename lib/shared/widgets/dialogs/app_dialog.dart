import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({this.title, this.content, this.actions, super.key});

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => AlertDialog(
    insetPadding: EdgeInsets.symmetric(
      horizontal: context.screenType.screenPadding,
      vertical: SpacingTokens.xl,
    ),
    constraints: BoxConstraints(maxWidth: _maxWidth(context)),
    title: title,
    content: _content,
    actions: actions,
  );

  Widget? get _content {
    final child = content;

    if (child == null) {
      return null;
    }

    return SizedBox(width: double.maxFinite, child: child);
  }

  double _maxWidth(BuildContext context) {
    if (context.isCompact) {
      return context.screenWidth - (context.screenType.screenPadding * 2);
    }

    if (context.isMedium) {
      return SizeTokens.dialogWidthMd;
    }

    return SizeTokens.dialogWidthLg;
  }
}
