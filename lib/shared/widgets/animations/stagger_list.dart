import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/shared/widgets/animations/fade_in_widget.dart';

class StaggerList extends StatelessWidget {
  const StaggerList({
    required this.children,
    this.staggerDelay = DurationTokens.staggerDelay,
    this.itemDuration = DurationTokens.normal,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    super.key,
  });

  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: crossAxisAlignment,
    children: List<Widget>.generate(
      children.length,
      (index) => FadeInWidget(
        delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
        duration: itemDuration,
        child: children[index],
      ),
    ),
  );
}
