import 'package:flutter/services.dart';

mixin HapticMixin {
  Future<void> lightImpact() => HapticFeedback.lightImpact();

  Future<void> mediumImpact() => HapticFeedback.mediumImpact();

  Future<void> selectionClick() => HapticFeedback.selectionClick();
}
