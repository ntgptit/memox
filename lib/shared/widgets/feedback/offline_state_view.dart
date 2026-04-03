import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class OfflineStateView extends StatelessWidget {
  const OfflineStateView({
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onRetry,
    super.key,
  });

  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => EmptyStateView(
    icon: Icons.cloud_off_outlined,
    title: title ?? context.l10n.offlineStateTitle,
    subtitle: subtitle ?? context.l10n.offlineStateSubtitle,
    actionLabel: onRetry == null
        ? null
        : actionLabel ?? context.l10n.retryAction,
    onAction: onRetry,
  );
}
