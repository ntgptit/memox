import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/services/database_export_service.dart';

DatabaseExportService createDatabaseExportService(AppLogger _) =>
    const UnsupportedDatabaseExportService();

final class UnsupportedDatabaseExportService implements DatabaseExportService {
  const UnsupportedDatabaseExportService();

  @override
  bool get isSupported => false;

  @override
  Future<DatabaseExportResult> exportCurrentDatabase() async =>
      const DatabaseExportFailure(DatabaseExportFailureReason.unsupported);
}
