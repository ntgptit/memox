extension StringX on String {
  bool get isBlank => trim().isEmpty;

  String get capitalized {
    if (isBlank) {
      return this;
    }

    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
