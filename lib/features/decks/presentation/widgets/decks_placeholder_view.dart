import 'package:flutter/material.dart';
import 'package:memox/core/constants/app_strings.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class DecksPlaceholderView extends StatelessWidget {
  const DecksPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) => const EmptyStateView(
    icon: Icons.style_outlined,
    title: AppStrings.decksTitle,
    subtitle: AppStrings.decksSubtitle,
  );
}
