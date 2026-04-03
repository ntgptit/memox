enum DatabaseExportFailureReason { unsupported, unavailable, unexpected }

sealed class DatabaseExportResult {
  const DatabaseExportResult();
}

final class DatabaseExportSuccess extends DatabaseExportResult {
  const DatabaseExportSuccess({required this.fileName});

  final String fileName;
}

final class DatabaseExportFailure extends DatabaseExportResult {
  const DatabaseExportFailure(this.reason);

  final DatabaseExportFailureReason reason;
}

abstract interface class DatabaseExportService {
  bool get isSupported;

  Future<DatabaseExportResult> exportCurrentDatabase();
}
