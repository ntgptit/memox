import 'package:dio/dio.dart';
import 'package:memox/core/network/api_endpoints.dart';
import 'package:memox/core/network/dto/sync_payload_dto.dart';

final class SyncApi {
  const SyncApi(this._dio);

  final Dio _dio;

  Future<SyncPayloadDto> pullChanges(String lastSyncTimestamp) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.syncPull,
      queryParameters: <String, dynamic>{
        'since': lastSyncTimestamp,
      },
    );

    return SyncPayloadDto.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> pushChanges(SyncPayloadDto payload) async {
    await _dio.post<void>(
      ApiEndpoints.syncPush,
      data: payload.toJson(),
    );
  }
}
