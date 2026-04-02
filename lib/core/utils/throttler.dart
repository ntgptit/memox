import 'dart:async';

final class Throttler {
  Throttler(this.duration);

  final Duration duration;
  bool _locked = false;

  void call(void Function() action) {
    if (_locked) {
      return;
    }

    _locked = true;
    action();
    unawaited(
      Future<void>.delayed(duration, () {
        _locked = false;
      }),
    );
  }
}
