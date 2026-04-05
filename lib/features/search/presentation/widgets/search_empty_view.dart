import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/shared/widgets/feedback/empty_state_view.dart';

class SearchEmptyView extends StatelessWidget {
  const SearchEmptyView({required this.hasQuery, super.key});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    if (hasQuery) {
      return EmptyStateView(
        icon: Icons.search_off_outlined,
        title: context.l10n.searchNoResultsTitle,
        subtitle: context.l10n.searchNoResultsSubtitle,
      );
    }

    return EmptyStateView(
      icon: Icons.search_outlined,
      title: context.l10n.searchIdleTitle,
      subtitle: context.l10n.searchIdleSubtitle,
    );
  }
}
