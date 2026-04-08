import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/statistics/presentation/providers/recent_study_sessions_provider.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/lists/app_list_tile.dart';

class RecentStudySessionsSection extends ConsumerWidget {
  const RecentStudySessionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(recentStudySessionsProvider);
    final sessions = sessionsAsync.asData?.value;

    if (sessions == null || sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.statisticsRecentSessionsTitle,
          style: context.textTheme.titleLarge,
        ),
        const SizedBox(height: SpacingTokens.md),
        AppCard(
          child: Column(
            children: [
              for (var index = 0; index < sessions.length; index++)
                AppListTile(
                  title: sessions[index].deckName,
                  subtitle: _subtitle(context, sessions[index]),
                  trailing: Text(
                    '${sessions[index].session.correctCount}/${sessions[index].session.totalCards}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  showDivider: index < sessions.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _subtitle(BuildContext context, RecentStudySessionItem item) {
    final completedAt = item.session.completedAt;

    if (completedAt == null) {
      return item.session.mode.label(context.l10n);
    }

    final date = DateFormat.yMMMd().add_Hm().format(completedAt.toLocal());
    return '${item.session.mode.label(context.l10n)} · $date';
  }
}
