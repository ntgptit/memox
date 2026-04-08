import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

enum AppSwipeDirection { left, right, up, down }

class AppSwipeRegion extends StatefulWidget {
  const AppSwipeRegion({
    required this.child,
    required this.onSwipe,
    this.behavior = HitTestBehavior.deferToChild,
    super.key,
  });

  final Widget child;
  final ValueChanged<AppSwipeDirection>? onSwipe;
  final HitTestBehavior behavior;

  @override
  State<AppSwipeRegion> createState() => _AppSwipeRegionState();
}

class _AppSwipeRegionState extends State<AppSwipeRegion> {
  Offset _delta = Offset.zero;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: widget.behavior,
    onPanUpdate: (details) => _delta += details.delta,
    onPanEnd: (_) => _emitSwipe(),
    onPanCancel: _resetDelta,
    child: widget.child,
  );

  void _emitSwipe() {
    final onSwipe = widget.onSwipe;
    final dx = _delta.dx;
    final dy = _delta.dy;
    final horizontal = dx.abs();
    final vertical = dy.abs();
    _resetDelta();

    if (onSwipe == null) {
      return;
    }

    if (horizontal < SizeTokens.touchTarget &&
        vertical < SizeTokens.touchTarget) {
      return;
    }

    if (horizontal > vertical) {
      onSwipe(dx > 0 ? AppSwipeDirection.right : AppSwipeDirection.left);
      return;
    }

    onSwipe(dy > 0 ? AppSwipeDirection.down : AppSwipeDirection.up);
  }

  void _resetDelta() => _delta = Offset.zero;
}
