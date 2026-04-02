import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';

final Provider<Color> seedColorProvider = Provider<Color>(
  (ref) => ColorTokens.seed,
);
