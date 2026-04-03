import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class UnauthorizedStateView extends StatelessWidget {
  const UnauthorizedStateView({
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onSignInAgain,
    super.key,
  });

  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onSignInAgain;

  @override
  Widget build(BuildContext context) => EmptyStateView(
    icon: Icons.lock_clock_outlined,
    title: title ?? context.l10n.unauthorizedStateTitle,
    subtitle: subtitle ?? context.l10n.unauthorizedStateSubtitle,
    actionLabel: onSignInAgain == null
        ? null
        : actionLabel ?? context.l10n.signInAgainAction,
    onAction: onSignInAgain,
  );
}
