import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class CardsPlaceholderView extends StatelessWidget {
  const CardsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) => EmptyStateView(
    icon: Icons.quiz_outlined,
    title: context.l10n.cardsTitle,
    subtitle: context.l10n.cardsSubtitle,
  );
}
