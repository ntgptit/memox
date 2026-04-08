import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/features/study/domain/fill/fill_engine.dart';
import 'package:memox/features/study/presentation/widgets/fill_submit_button.dart';
import 'package:memox/shared/widgets/inputs/app_text_field.dart';

class FillAnswerInput extends StatelessWidget {
  const FillAnswerInput({
    required this.controller,
    required this.focusNode,
    required this.result,
    required this.isRetrying,
    required this.canSubmit,
    required this.isNumericAnswer,
    required this.onChanged,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FillResult? result;
  final bool isRetrying;
  final bool canSubmit;
  final bool isNumericAnswer;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: controller,
    focusNode: focusNode,
    autofocus: true,
    label: context.l10n.fillAnswerLabel,
    hint: isRetrying
        ? context.l10n.fillRetryInputHint
        : context.l10n.fillAnswerHint,
    onChanged: onChanged,
    onSubmitted: (_) => onSubmit(),
    textInputAction: TextInputAction.done,
    keyboardType: isNumericAnswer ? TextInputType.number : TextInputType.text,
    readOnly: result == FillResult.close || result == FillResult.correct,
    textAlign: TextAlign.center,
    prefixIcon: result == FillResult.correct
        ? Icon(
            Icons.check_circle_outlined,
            color: context.customColors.ratingGood,
          )
        : null,
    suffixIcon: Padding(
      padding: const EdgeInsets.only(right: SpacingTokens.sm),
      child: FillSubmitButton(enabled: canSubmit, onTap: onSubmit),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
    enabledBorder: _border(context),
    focusedBorder: _border(context),
    disabledBorder: _border(context),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
  );

  OutlineInputBorder _border(BuildContext context) => OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(RadiusTokens.input)),
    borderSide: BorderSide(color: _borderColor(context)),
  );

  Color _borderColor(BuildContext context) => switch (result) {
    FillResult.correct => context.customColors.ratingGood.withValues(
      alpha: OpacityTokens.focus,
    ),
    FillResult.close => context.customColors.ratingHard.withValues(
      alpha: OpacityTokens.focus,
    ),
    FillResult.wrong => context.colors.error.withValues(
      alpha: OpacityTokens.focus,
    ),
    null => context.colors.outline,
  };
}
