// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:drift/wasm.dart';
import 'package:memox/core/database/db_constants.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/services/database_export_service.dart';

DatabaseExportService createDatabaseExportService(AppLogger logger) =>
    WebDatabaseExportService(logger);

final class WebDatabaseExportService implements DatabaseExportService {
  const WebDatabaseExportService(this._logger);

  final AppLogger _logger;

  @override
  bool get isSupported => true;

  @override
  Future<DatabaseExportResult> exportCurrentDatabase() async {
    try {
      final probeResult = await WasmDatabase.probe(
        sqlite3Uri: Uri.parse(DbConstants.webSqliteWasmFileName),
        driftWorkerUri: Uri.parse(DbConstants.webDriftWorkerFileName),
        databaseName: DbConstants.databaseName,
      );
      final database = _findDatabase(probeResult.existingDatabases);
      if (database == null) {
        _logger.warning('No persisted web database named memox_database found');
        return const DatabaseExportFailure(
          DatabaseExportFailureReason.unavailable,
        );
      }
      final bytes = await probeResult.exportDatabase(database);
      if (bytes == null || bytes.isEmpty) {
        _logger.warning('Failed to read bytes from web database memox_database');
        return const DatabaseExportFailure(
          DatabaseExportFailureReason.unavailable,
        );
      }
      _download(bytes);
      _logger.info(
        'Exported web database memox_database to ${DbConstants.sqliteFileName}',
      );
      return const DatabaseExportSuccess(fileName: DbConstants.sqliteFileName);
    } catch (error, stackTrace) {
      _logger.error(
        'Web database export failed',
        error: error,
        stackTrace: stackTrace,
      );
      return const DatabaseExportFailure(
        DatabaseExportFailureReason.unexpected,
      );
    }
  }

  ExistingDatabase? _findDatabase(List<ExistingDatabase> databases) {
    for (final database in databases) {
      if (database.$2 == DbConstants.databaseName) {
        return database;
      }
    }

    return null;
  }

  void _download(Uint8List bytes) {
    final blob = html.Blob([bytes], DbConstants.sqliteMimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = DbConstants.sqliteFileName;
    html.document.body?.children.add(anchor);
    anchor
      ..click()
      ..remove();
    html.Url.revokeObjectUrl(url);
  }
}
