extension IterableX<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T value) predicate) {
    for (final value in this) {
      if (predicate(value)) {
        return value;
      }
    }

    return null;
  }
}
