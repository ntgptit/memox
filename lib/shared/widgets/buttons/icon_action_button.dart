import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class IconActionButton extends StatelessWidget {
  const IconActionButton({
    required this.icon,
    this.onTap,
    this.tooltip,
    this.size = SizeTokens.touchTarget,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) => IconButton.outlined(
    onPressed: onTap,
    tooltip: tooltip,
    style: IconButton.styleFrom(minimumSize: Size.square(size)),
    icon: Icon(icon, size: SizeTokens.iconMd),
  );
}
