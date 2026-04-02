import 'package:dio/dio.dart';
import 'package:memox/core/services/secure_storage_service.dart';

final class AuthInterceptor extends Interceptor {
  const AuthInterceptor(this._secureStorageService);

  static const String _accessTokenKey = 'access_token';

  final SecureStorageService _secureStorageService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorageService.read(_accessTokenKey);

    if (token == null || token.isEmpty) {
      handler.next(options);
      return;
    }

    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
