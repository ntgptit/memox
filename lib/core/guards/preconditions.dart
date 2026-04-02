mixin Preconditions {
  static void requireNotEmpty(String value, {String name = 'value'}) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, '$name must not be empty');
    }
  }

  static void requirePositive(num value, {String name = 'value'}) {
    if (value <= 0) {
      throw ArgumentError.value(value, name, '$name must be positive');
    }
  }

  static void requireInRange(
    num value,
    num min,
    num max, {
    String name = 'value',
  }) {
    if (value < min || value > max) {
      throw ArgumentError.value(
        value,
        name,
        '$name must be between $min and $max',
      );
    }
  }
}
