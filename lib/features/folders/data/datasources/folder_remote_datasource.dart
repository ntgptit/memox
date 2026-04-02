import 'package:memox/core/network/api/sync_api.dart';
import 'package:memox/core/network/dto/folder_dto.dart';
import 'package:memox/core/network/dto/sync_payload_dto.dart';

abstract interface class FolderRemoteDataSource {
  Future<List<FolderDto>> fetchAll(String sinceTimestamp);

  Future<void> pushChanges(List<FolderDto> folders);
}

final class FolderRemoteDataSourceImpl implements FolderRemoteDataSource {
  const FolderRemoteDataSourceImpl(this._api);

  final SyncApi _api;

  @override
  Future<List<FolderDto>> fetchAll(String sinceTimestamp) async {
    final payload = await _api.pullChanges(sinceTimestamp);
    return payload.folders;
  }

  @override
  Future<void> pushChanges(List<FolderDto> folders) {
    return _api.pushChanges(SyncPayloadDto(folders: folders));
  }
}
