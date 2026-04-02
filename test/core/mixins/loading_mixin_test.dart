import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/mixins/loading_mixin.dart';

void main() {
  test('guard toggles loading state and returns result', () async {
    final harness = _LoadingHarness();
    final completer = Completer<int>();

    final future = harness.guard(() => completer.future);

    expect(harness.isLoading, isTrue);
    expect(harness.error, isNull);
    expect(harness.hasError, isFalse);

    completer.complete(7);

    expect(await future, 7);
    expect(harness.isLoading, isFalse);
    expect(harness.error, isNull);
    expect(harness.hasError, isFalse);
  });

  test('guard captures error and clears previous error on next run', () async {
    final harness = _LoadingHarness();

    expect(
      await harness.guard<int>(() async => throw StateError('boom')),
      isNull,
    );
    expect(harness.isLoading, isFalse);
    expect(harness.hasError, isTrue);
    expect(harness.error, contains('boom'));

    final completer = Completer<String>();
    final future = harness.guard(() => completer.future);

    expect(harness.isLoading, isTrue);
    expect(harness.error, isNull);
    expect(harness.hasError, isFalse);

    completer.complete('ok');

    expect(await future, 'ok');
    expect(harness.isLoading, isFalse);
    expect(harness.error, isNull);
  });
}

class _LoadingHarness with LoadingMixin {}
