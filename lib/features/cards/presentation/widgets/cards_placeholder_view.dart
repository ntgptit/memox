import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class CardsPlaceholderView extends StatelessWidget {
  const CardsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) => const EmptyStateView(
    icon: Icons.quiz_outlined,
    title: AppStrings.cardsTitle,
    subtitle: AppStrings.cardsSubtitle,
  );
}
