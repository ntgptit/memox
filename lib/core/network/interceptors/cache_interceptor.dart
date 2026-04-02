import 'package:dio/dio.dart';

final class CacheInterceptor extends Interceptor {
  const CacheInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final etag = options.extra['etag'] as String?;
    final modifiedSince = options.extra['modified_since'] as String?;

    if (etag != null && etag.isNotEmpty) {
      options.headers['If-None-Match'] = etag;
    }

    if (modifiedSince != null && modifiedSince.isNotEmpty) {
      options.headers['If-Modified-Since'] = modifiedSince;
    }

    handler.next(options);
  }
}
