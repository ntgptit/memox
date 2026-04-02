import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

class ShakeWidget extends StatefulWidget {
  const ShakeWidget({required this.child, required this.isShaking, super.key});

  final Widget child;
  final bool isShaking;

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DurationTokens.shake,
    );
  }

  @override
  void didUpdateWidget(covariant ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      final offset =
          math.sin(_controller.value * math.pi * 4) * SpacingTokens.xs;
      return Transform.translate(offset: Offset(offset, 0), child: child);
    },
    child: widget.child,
  );
}
