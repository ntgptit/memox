abstract interface class SecureStorageService {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> delete(String key);
}

final class InMemorySecureStorageService implements SecureStorageService {
  const InMemorySecureStorageService();

  static final Map<String, String> _storage = <String, String>{};

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<String?> read(String key) async => _storage[key];

  @override
  Future<void> write(String key, String value) async {
    _storage[key] = value;
  }
}
