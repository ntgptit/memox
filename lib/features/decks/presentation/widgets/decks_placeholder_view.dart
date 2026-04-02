import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class DecksPlaceholderView extends StatelessWidget {
  const DecksPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) => EmptyStateView(
    icon: Icons.style_outlined,
    title: context.l10n.decksTitle,
    subtitle: context.l10n.decksSubtitle,
  );
}
