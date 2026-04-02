import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';

class ScaleTap extends StatefulWidget {
  const ScaleTap({
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  @override
  State<ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<ScaleTap> {
  var _pressed = false;

  void _setPressed(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    onTapDown: (_) => _setPressed(true),
    onTapUp: (_) => _setPressed(false),
    onTapCancel: () => _setPressed(false),
    child: AnimatedScale(
      scale: _pressed ? widget.scaleDown : 1,
      duration: DurationTokens.fast,
      child: widget.child,
    ),
  );
}
