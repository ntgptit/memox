import 'package:flutter/material.dart';

class AppTapRegion extends StatelessWidget {
  const AppTapRegion({
    required this.child,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.behavior = HitTestBehavior.deferToChild,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final VoidCallback? onTapCancel;
  final HitTestBehavior behavior;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: behavior,
    onTap: onTap,
    onTapDown: onTapDown,
    onTapUp: onTapUp,
    onTapCancel: onTapCancel,
    child: child,
  );
}
