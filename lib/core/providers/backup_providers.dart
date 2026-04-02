import 'package:google_sign_in/google_sign_in.dart';
import 'package:memox/core/backup/backup_service.dart';
import 'package:memox/core/backup/google_drive_service.dart';
import 'package:memox/core/providers/database_providers.dart';
import 'package:memox/core/providers/service_providers.dart';
import 'package:memox/core/services/google_sign_in_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_providers.g.dart';

@Riverpod(keepAlive: true)
GoogleSignInService googleSignInService(Ref ref) => GoogleSignInService();

@Riverpod(keepAlive: true)
GoogleDriveService googleDriveService(Ref ref) =>
    GoogleDriveService(ref.watch(googleSignInServiceProvider));

@Riverpod(keepAlive: true)
BackupService backupService(Ref ref) => BackupService(
  ref.watch(appDatabaseProvider),
  ref.watch(googleDriveServiceProvider),
  ref.watch(appLoggerProvider),
);

@Riverpod(keepAlive: true)
Future<GoogleSignInAccount?> currentGoogleUser(Ref ref) async =>
    ref.watch(googleSignInServiceProvider).signInSilently();
