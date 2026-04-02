import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({this.size = SizeTokens.buttonHeightSm, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox.square(
      dimension: size,
      child: const CircularProgressIndicator(
        strokeWidth: SizeTokens.borderWidth,
      ),
    ),
  );
}
