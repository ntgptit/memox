import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class AppTileGlyph extends StatelessWidget {
  const AppTileGlyph({required this.icon, required this.color, super.key});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color.withValues(alpha: OpacityTokens.focus),
      borderRadius: BorderRadius.circular(RadiusTokens.md),
    ),
    child: SizedBox.square(
      dimension: SizeTokens.avatarLg,
      child: Icon(icon, color: color),
    ),
  );
}
