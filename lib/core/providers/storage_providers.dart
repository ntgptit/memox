import 'package:memox/core/services/secure_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'storage_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(Ref ref) {
  return const InMemorySecureStorageService();
}
