import 'package:flutter/material.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';

class RecallHighlightedText extends StatelessWidget {
  const RecallHighlightedText({
    required this.text,
    required this.matchingKeywords,
    required this.emphasisKeywords,
    required this.emphasisColor,
    super.key,
  });

  final String text;
  final Set<String> matchingKeywords;
  final Set<String> emphasisKeywords;
  final Color emphasisColor;

  @override
  Widget build(BuildContext context) {
    final baseStyle = context.textTheme.bodyMedium?.copyWith(
      height: TypographyTokens.relaxedHeight,
    );
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: _segments(text)
            .map((segment) {
              if (segment.trim().isEmpty) {
                return TextSpan(text: segment);
              }

              final keyword = _normalize(segment);

              if (keyword.isEmpty) {
                return TextSpan(text: segment);
              }

              if (emphasisKeywords.contains(keyword)) {
                return TextSpan(
                  text: segment,
                  style: baseStyle?.copyWith(
                    backgroundColor: emphasisColor.withValues(
                      alpha: OpacityTokens.selected,
                    ),
                  ),
                );
              }

              if (matchingKeywords.contains(keyword)) {
                return TextSpan(
                  text: segment,
                  style: baseStyle?.copyWith(
                    backgroundColor: context.customColors.success.withValues(
                      alpha: OpacityTokens.selected,
                    ),
                  ),
                );
              }

              return TextSpan(text: segment);
            })
            .toList(growable: false),
      ),
    );
  }
}

Iterable<String> _segments(String text) =>
    RegExp(r'\s+|\S+').allMatches(text).map((match) => match.group(0) ?? '');

String _normalize(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[.,!?;:()\[\]{}]'), '')
    .replaceAll("'", '')
    .replaceAll('"', '')
    .replaceAll('`', '');
