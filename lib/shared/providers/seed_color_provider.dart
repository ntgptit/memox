import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';

final StateProvider<Color> seedColorProvider = StateProvider<Color>(
  (ref) => ColorTokens.seed,
);
