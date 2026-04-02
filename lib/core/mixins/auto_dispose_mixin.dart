mixin AutoDisposeMixin {
  final List<void Function()> _disposeCallbacks = <void Function()>[];

  void onDispose(void Function() callback) => _disposeCallbacks.add(callback);

  void disposeRegisteredResources() {
    for (final callback in _disposeCallbacks.reversed) {
      callback();
    }
    _disposeCallbacks.clear();
  }
}
