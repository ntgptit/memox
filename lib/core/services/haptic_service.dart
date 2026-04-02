import 'package:flutter/services.dart';

abstract interface class HapticService {
  Future<void> lightImpact();

  Future<void> mediumImpact();

  Future<void> selectionClick();
}

final class SystemHapticService implements HapticService {
  const SystemHapticService();

  @override
  Future<void> lightImpact() => HapticFeedback.lightImpact();

  @override
  Future<void> mediumImpact() => HapticFeedback.mediumImpact();

  @override
  Future<void> selectionClick() => HapticFeedback.selectionClick();
}
