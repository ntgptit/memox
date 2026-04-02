import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';

class PulseWidget extends StatefulWidget {
  const PulseWidget({
    required this.child,
    this.minOpacity = 0.6,
    this.maxOpacity = 1,
    this.duration = DurationTokens.pulse,
    super.key,
  });

  final Widget child;
  final double minOpacity;
  final double maxOpacity;
  final Duration duration;

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    unawaited(_controller.repeat(reverse: true));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
    child: widget.child,
  );
}
