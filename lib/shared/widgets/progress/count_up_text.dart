import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/shared/widgets/animations/count_up_animation.dart';

class CountUpText extends StatelessWidget {
  const CountUpText({
    required this.endValue,
    required this.style,
    this.duration = DurationTokens.countUp,
    this.prefix = '',
    this.suffix = '',
    super.key,
  });

  final num endValue;
  final TextStyle style;
  final Duration duration;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) => CountUpAnimation(
    end: endValue.toDouble(),
    duration: duration,
    builder: (context, value) => Text(
      '$prefix${_formatValue(value)}$suffix',
      style: style,
    ),
  );

  String _formatValue(double value) {
    if (endValue is int) {
      return value.round().toString();
    }

    final rounded = value.toStringAsFixed(1);
    return rounded.endsWith('.0')
        ? rounded.substring(0, rounded.length - 2)
        : rounded;
  }
}
