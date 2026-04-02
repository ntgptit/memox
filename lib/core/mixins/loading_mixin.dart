/// For Riverpod AsyncNotifiers or any class managing async state.
mixin LoadingMixin {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasError => _error != null;

  /// Wrap any async operation with loading/error handling.
  Future<T?> guard<T>(Future<T> Function() action) async {
    _isLoading = true;
    _error = null;

    try {
      final result = await action();
      return result;
    } catch (error) {
      _error = error.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }
}
