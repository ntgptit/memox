import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/network/api/backup_api.dart';
import 'package:memox/core/network/api/sync_api.dart';
import 'package:memox/core/network/dio_client.dart';
import 'package:memox/core/providers/service_providers.dart';
import 'package:memox/core/providers/storage_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_providers.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  return DioClient.create(
    logger: ref.watch(appLoggerProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
  );
}

@Riverpod(keepAlive: true)
SyncApi syncApi(Ref ref) {
  return SyncApi(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
BackupApi backupApi(Ref ref) {
  return BackupApi(ref.watch(dioProvider));
}
