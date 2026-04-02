import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/shared/widgets/animations/fade_in_widget.dart';

class AnimatedListView extends StatelessWidget {
  const AnimatedListView({
    required this.children,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.staggerDelay = DurationTokens.staggerDelay,
    this.itemDuration = DurationTokens.normal,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final Duration staggerDelay;
  final Duration itemDuration;

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: padding,
    controller: controller,
    shrinkWrap: shrinkWrap,
    itemCount: children.length,
    itemBuilder: (context, index) => FadeInWidget(
      delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
      duration: itemDuration,
      child: children[index],
    ),
  );
}
