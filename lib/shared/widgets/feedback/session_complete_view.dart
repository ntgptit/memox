import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/buttons/primary_button.dart';
import 'package:memox/shared/widgets/buttons/text_link_button.dart';
import 'package:memox/shared/widgets/feedback/success_indicator.dart';

part 'session_complete_view.freezed.dart';

class SessionCompleteView extends StatelessWidget {
  const SessionCompleteView({
    required this.stats,
    required this.primaryAction,
    this.secondaryAction,
    this.extraContent,
    super.key,
  });

  final List<SessionStat> stats;
  final SessionAction primaryAction;
  final SessionAction? secondaryAction;
  final Widget? extraContent;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(SpacingTokens.xl),
    child:
        Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SuccessIndicator(),
                const SizedBox(height: SpacingTokens.lg),
                Text(
                  context.l10n.sessionCompleteTitle,
                  style: context.appTextStyles.statNumberSm,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SpacingTokens.xl),
                ...stats.map((stat) => _SessionStatRow(stat: stat)),
                if (extraContent != null) ...[
                  const SizedBox(height: SpacingTokens.xl),
                  extraContent!,
                ],
                const SizedBox(height: SpacingTokens.xl),
                PrimaryButton(
                  label: primaryAction.label,
                  onPressed: primaryAction.onTap,
                ),
                if (secondaryAction != null) ...[
                  const SizedBox(height: SpacingTokens.lg),
                  Center(
                    child: TextLinkButton(
                      label: secondaryAction!.label,
                      onTap: secondaryAction!.onTap,
                    ),
                  ),
                ],
              ],
            )
            .animate()
            .fadeIn(duration: DurationTokens.slow)
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
              duration: DurationTokens.slow,
            ),
  );
}

class _SessionStatRow extends StatelessWidget {
  const _SessionStatRow({required this.stat});

  final SessionStat stat;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: SpacingTokens.md),
    child: Row(
      children: [
        Icon(stat.icon, size: SizeTokens.iconXs, color: stat.valueColor),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Text(
            stat.label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: stat.valueColor ?? context.colors.onSurface,
            ),
          ),
        ),
      ],
    ),
  );
}

@freezed
abstract class SessionStat with _$SessionStat {
  const factory SessionStat({
    required String label,
    required IconData icon,
    Color? valueColor,
  }) = _SessionStat;
}

@freezed
abstract class SessionAction with _$SessionAction {
  const factory SessionAction({
    required String label,
    required VoidCallback onTap,
  }) = _SessionAction;
}
