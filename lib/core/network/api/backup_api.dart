import 'package:dio/dio.dart';
import 'package:memox/core/network/api_endpoints.dart';
import 'package:memox/core/network/dto/sync_payload_dto.dart';

final class BackupApi {
  const BackupApi(this._dio);

  final Dio _dio;

  Future<void> createBackup(SyncPayloadDto payload) async {
    await _dio.post<void>(
      ApiEndpoints.backups,
      data: payload.toJson(),
    );
  }

  Future<SyncPayloadDto> restoreBackup(String backupId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.backups}/$backupId',
    );

    return SyncPayloadDto.fromJson(response.data ?? <String, dynamic>{});
  }
}
