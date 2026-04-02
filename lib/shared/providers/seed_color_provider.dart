import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'seed_color_provider.g.dart';

@Riverpod(keepAlive: true)
Color seedColor(Ref ref) => ColorTokens.seed;
