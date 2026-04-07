import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

enum AppDialogVariant { standard, form }

class AppDialog extends StatelessWidget {
  const AppDialog({
    this.title,
    this.content,
    this.actions,
    this.variant = AppDialogVariant.standard,
    super.key,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final AppDialogVariant variant;

  @override
  Widget build(BuildContext context) {
    final layout = _AppDialogLayout.fromVariant(variant);

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.screenType.screenPadding,
        vertical: SpacingTokens.xl,
      ),
      scrollable: true,
      constraints: BoxConstraints(maxWidth: _dialogMaxWidth(context)),
      title: title,
      content: _wrapDialogContent(content),
      actions: actions,
      titlePadding: layout.titlePadding,
      contentPadding: layout.contentPadding,
      actionsPadding: layout.actionsPadding,
      buttonPadding: const EdgeInsets.only(left: SpacingTokens.sm),
      actionsAlignment: MainAxisAlignment.end,
    );
  }
}

Widget? _wrapDialogContent(Widget? content) {
  if (content == null) {
    return null;
  }

  return SizedBox(width: double.maxFinite, child: content);
}

double _dialogMaxWidth(BuildContext context) {
  if (context.isCompact) {
    return context.screenWidth - (context.screenType.screenPadding * 2);
  }

  if (context.isMedium) {
    return SizeTokens.dialogWidthMd;
  }

  return SizeTokens.dialogWidthLg;
}

class _AppDialogLayout {
  const _AppDialogLayout({
    required this.titlePadding,
    required this.contentPadding,
    required this.actionsPadding,
  });

  factory _AppDialogLayout.fromVariant(AppDialogVariant variant) =>
      switch (variant) {
        AppDialogVariant.form => const _AppDialogLayout(
          titlePadding: _sharedTitlePadding,
          contentPadding: EdgeInsets.fromLTRB(
            SpacingTokens.xl,
            0,
            SpacingTokens.xl,
            0,
          ),
          actionsPadding: EdgeInsets.fromLTRB(
            SpacingTokens.xl,
            SpacingTokens.lg,
            SpacingTokens.xl,
            SpacingTokens.xl,
          ),
        ),
        AppDialogVariant.standard => const _AppDialogLayout(
          titlePadding: _sharedTitlePadding,
          contentPadding: EdgeInsets.fromLTRB(
            SpacingTokens.xl,
            0,
            SpacingTokens.xl,
            SpacingTokens.lg,
          ),
          actionsPadding: EdgeInsets.fromLTRB(
            SpacingTokens.xl,
            0,
            SpacingTokens.xl,
            SpacingTokens.xl,
          ),
        ),
      };

  final EdgeInsetsGeometry titlePadding;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry actionsPadding;

  static const _sharedTitlePadding = EdgeInsets.fromLTRB(
    SpacingTokens.xl,
    SpacingTokens.xl,
    SpacingTokens.xl,
    SpacingTokens.sm,
  );
}
