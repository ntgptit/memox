import 'dart:async';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:memox/core/services/google_sign_in_service.dart';

class GoogleDriveService {
  const GoogleDriveService(this._authService);

  final GoogleSignInService _authService;

  Future<drive.DriveApi?> _getDriveApi() async {
    final client = await _authService.getAuthClient();
    if (client == null) {
      return null;
    }
    return drive.DriveApi(client);
  }

  Future<String?> uploadBackup({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
    String? existingFileId,
  }) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      return null;
    }
    final driveFile = drive.File()
      ..name = fileName
      ..modifiedTime = DateTime.now().toUtc();
    final media = drive.Media(
      Stream<List<int>>.value(bytes),
      bytes.length,
      contentType: mimeType,
    );
    if (existingFileId != null && existingFileId.isNotEmpty) {
      final response = await driveApi.files.update(
        driveFile,
        existingFileId,
        uploadMedia: media,
      );
      return response.id;
    }
    driveFile.parents = <String>['appDataFolder'];
    final response = await driveApi.files.create(driveFile, uploadMedia: media);
    return response.id;
  }

  Future<List<int>?> downloadBackup(String fileId) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      return null;
    }
    final media =
        await driveApi.files.get(
              fileId,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;
    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }
    return bytes;
  }

  Future<List<drive.File>> listBackups() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      return const <drive.File>[];
    }
    final fileList = await driveApi.files.list(
      spaces: 'appDataFolder',
      orderBy: 'modifiedTime desc',
      $fields: 'files(id, name, modifiedTime, size)',
    );
    return fileList.files ?? const <drive.File>[];
  }

  Future<void> deleteBackup(String fileId) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      return;
    }
    await driveApi.files.delete(fileId);
  }
}
