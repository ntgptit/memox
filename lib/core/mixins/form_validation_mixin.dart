mixin FormValidationMixin {
  final Map<String, String?> _errors = <String, String?>{};

  Map<String, String?> get errors => Map.unmodifiable(_errors);

  bool get hasValidationErrors => _errors.values.any((value) => value != null);

  void clearValidationErrors() => _errors.clear();

  void setFieldError(String field, String? error) {
    _errors[field] = error;
  }
}
