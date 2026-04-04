import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class ReviewCardFace extends StatelessWidget {
  const ReviewCardFace({
    required this.text,
    this.eyebrow,
    this.hint,
    this.example,
    this.onTap,
    super.key,
  });

  final String text;
  final String? eyebrow;
  final String? hint;
  final String? example;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    backgroundColor: context.colors.surfaceContainerHighest,
    padding: const EdgeInsets.all(SpacingTokens.xl),
    child: SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (eyebrow != null)
            Text(
              eyebrow!,
              style: context.textTheme.labelSmall?.copyWith(
                letterSpacing: TypographyTokens.labelSpacing,
                color: context.colors.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          if (eyebrow != null) const Gap.md(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  style: context.appTextStyles.flashcardFront,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          if (hint != null) ...[
            const Gap.md(),
            Text(
              hint!,
              style: context.appTextStyles.flashcardHint,
              textAlign: TextAlign.center,
            ),
          ],
          if (example != null) ...[
            const Gap.sm(),
            Text(
              example!,
              style: context.appTextStyles.flashcardExample,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ),
  );
}
