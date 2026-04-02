mixin Validators {
  static String? requiredText(String value, {String fieldName = 'Field'}) {
    if (value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  static String? positiveInt(int value, {String fieldName = 'Value'}) {
    if (value <= 0) {
      return '$fieldName must be greater than zero';
    }

    return null;
  }
}
