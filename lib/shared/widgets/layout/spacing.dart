import 'package:flutter/widgets.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class Gap extends SizedBox {
  const Gap.xxs({super.key}) : super.square(dimension: SpacingTokens.xxs);

  const Gap.xs({super.key}) : super.square(dimension: SpacingTokens.xs);

  const Gap.sm({super.key}) : super.square(dimension: SpacingTokens.sm);

  const Gap.md({super.key}) : super.square(dimension: SpacingTokens.md);

  const Gap.lg({super.key}) : super.square(dimension: SpacingTokens.lg);

  const Gap.xl({super.key}) : super.square(dimension: SpacingTokens.xl);

  const Gap.xxl({super.key}) : super.square(dimension: SpacingTokens.xxl);

  const Gap.section({super.key})
    : super.square(dimension: SpacingTokens.sectionGap);
}
