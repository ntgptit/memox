import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/guess/guess_engine.dart';

class GuessOptionButton extends StatelessWidget {
  const GuessOptionButton({
    required this.option,
    required this.prefixLabel,
    required this.isAnswered,
    required this.isSelected,
    required this.isCorrectAnswer,
    required this.isWrongSelection,
    this.onTap,
    super.key,
  });

  final GuessOption option;
  final String prefixLabel;
  final bool isAnswered;
  final bool isSelected;
  final bool isCorrectAnswer;
  final bool isWrongSelection;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    duration: DurationTokens.normal,
    opacity: _guessOptionOpacity(
      isAnswered: isAnswered,
      isCorrectAnswer: isCorrectAnswer,
      isWrongSelection: isWrongSelection,
    ),
    child: AnimatedContainer(
      duration: DurationTokens.normal,
      curve: Curves.easeInOut,
      height: SizeTokens.inputHeight,
      decoration: BoxDecoration(
        color: _guessOptionHighlightColor(
          context,
          isCorrectAnswer: isCorrectAnswer,
          isWrongSelection: isWrongSelection,
          isSelected: isSelected,
          isAnswered: isAnswered,
        ),
        borderRadius: BorderRadius.circular(RadiusTokens.input),
        border: Border.all(
          color: _guessOptionBorderColor(
            context,
            isCorrectAnswer: isCorrectAnswer,
            isWrongSelection: isWrongSelection,
          ),
        ),
      ),
      child: Material(
        color: context.colors.surface.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(RadiusTokens.input),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(RadiusTokens.input),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
            child: _GuessOptionContent(
              option: option,
              prefixLabel: prefixLabel,
              contentColor: _guessOptionContentColor(
                context,
                isCorrectAnswer: isCorrectAnswer,
                isWrongSelection: isWrongSelection,
              ),
              trailingIcon: _guessOptionTrailingIcon(
                isCorrectAnswer: isCorrectAnswer,
                isWrongSelection: isWrongSelection,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _GuessOptionContent extends StatelessWidget {
  const _GuessOptionContent({
    required this.option,
    required this.prefixLabel,
    required this.contentColor,
    required this.trailingIcon,
  });

  final GuessOption option;
  final String prefixLabel;
  final Color contentColor;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        prefixLabel,
        style: context.appTextStyles.progressCount.copyWith(
          color: contentColor,
        ),
      ),
      const SizedBox(width: SpacingTokens.md),
      Expanded(
        child: Text(
          option.text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleSmall?.copyWith(color: contentColor),
        ),
      ),
      if (trailingIcon != null) ...[
        const SizedBox(width: SpacingTokens.md),
        Icon(trailingIcon, color: contentColor),
      ],
    ],
  );
}

Color _guessOptionBorderColor(
  BuildContext context, {
  required bool isCorrectAnswer,
  required bool isWrongSelection,
}) {
  if (isCorrectAnswer) {
    return context.customColors.success;
  }

  if (isWrongSelection) {
    return context.customColors.warning;
  }

  return context.colors.outline;
}

Color _guessOptionContentColor(
  BuildContext context, {
  required bool isCorrectAnswer,
  required bool isWrongSelection,
}) {
  if (isCorrectAnswer || isWrongSelection) {
    return context.colors.onPrimary;
  }

  return context.colors.onSurface;
}

Color _guessOptionHighlightColor(
  BuildContext context, {
  required bool isCorrectAnswer,
  required bool isWrongSelection,
  required bool isSelected,
  required bool isAnswered,
}) {
  if (isCorrectAnswer) {
    return context.customColors.success;
  }

  if (isWrongSelection) {
    return context.customColors.warning;
  }

  if (isSelected && !isAnswered) {
    return context.colors.primaryContainer;
  }

  return context.colors.surface;
}

IconData? _guessOptionTrailingIcon({
  required bool isCorrectAnswer,
  required bool isWrongSelection,
}) {
  if (isCorrectAnswer) {
    return Icons.check_outlined;
  }

  if (isWrongSelection) {
    return Icons.close_outlined;
  }

  return null;
}

double _guessOptionOpacity({
  required bool isAnswered,
  required bool isCorrectAnswer,
  required bool isWrongSelection,
}) {
  if (!isAnswered || isCorrectAnswer || isWrongSelection) {
    return 1;
  }

  return OpacityTokens.fadeOut;
}
