import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/services/database_export_service.dart';
import 'package:memox/core/services/database_export_service_stub.dart'
    if (dart.library.html)
        'package:memox/core/services/database_export_service_web.dart' as impl;

DatabaseExportService createDatabaseExportService(AppLogger logger) =>
    impl.createDatabaseExportService(logger);
