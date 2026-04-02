import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/network/api_endpoints.dart';
import 'package:memox/core/network/interceptors/auth_interceptor.dart';
import 'package:memox/core/network/interceptors/cache_interceptor.dart';
import 'package:memox/core/network/interceptors/error_interceptor.dart';
import 'package:memox/core/network/interceptors/logging_interceptor.dart';
import 'package:memox/core/network/interceptors/retry_interceptor.dart';
import 'package:memox/core/services/secure_storage_service.dart';

abstract final class DioClient {
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static Dio create({
    required AppLogger logger,
    required SecureStorageService secureStorageService,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
      ),
    );

    dio.interceptors.add(AuthInterceptor(secureStorageService));
    dio.interceptors.add(const CacheInterceptor());
    dio.interceptors.add(const ErrorInterceptor());
    dio.interceptors.add(RetryInterceptor(dio));

    if (kDebugMode) {
      dio.interceptors.add(LoggingInterceptor(logger));
    }

    return dio;
  }
}
