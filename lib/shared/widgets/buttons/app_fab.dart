import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';

class AppFab extends StatelessWidget {
  const AppFab({
    required this.icon,
    required this.onTap,
    this.label,
    this.tooltip,
    this.heroTag,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? label;
  final String? tooltip;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(RadiusTokens.fab),
    );

    if (label == null) {
      return FloatingActionButton(
        onPressed: onTap,
        tooltip: tooltip,
        heroTag: heroTag,
        shape: shape,
        child: Icon(icon),
      );
    }

    return FloatingActionButton.extended(
      onPressed: onTap,
      tooltip: tooltip,
      heroTag: heroTag,
      shape: shape,
      icon: Icon(icon),
      label: Text(label!),
    );
  }
}
