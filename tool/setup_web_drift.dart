import 'dart:convert';
import 'dart:io';

import 'package:memox/core/database/db_constants.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  final workspaceRoot = Directory.current.path;
  final driftRoot = await _resolvePackageRoot(
    packageName: 'drift',
    workspaceRoot: workspaceRoot,
  );
  final wasmSource = await _resolveSqliteWasmSource(driftRoot);
  final wasmTarget = p.join(
    workspaceRoot,
    'web',
    DbConstants.webSqliteWasmFileName,
  );

  await File(wasmSource).copy(wasmTarget);

  final compileProcess = await Process.start(
    Platform.resolvedExecutable,
    [
      'compile',
      'js',
      p.join('web', 'drift_worker.dart'),
      '-O2',
      '-o',
      p.join('web', DbConstants.webDriftWorkerFileName),
    ],
    workingDirectory: workspaceRoot,
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await compileProcess.exitCode;

  if (exitCode == 0) {
    return;
  }

  throw ProcessException(
    Platform.resolvedExecutable,
    <String>[
      'compile',
      'js',
      p.join('web', 'drift_worker.dart'),
      '-O2',
      '-o',
      p.join('web', DbConstants.webDriftWorkerFileName),
    ],
    'Failed to compile drift web worker.',
    exitCode,
  );
}

Future<String> _resolvePackageRoot({
  required String packageName,
  required String workspaceRoot,
}) async {
  final packageConfigFile = File(
    p.join(workspaceRoot, '.dart_tool', 'package_config.json'),
  );
  final packageConfig = jsonDecode(
    await packageConfigFile.readAsString(),
  ) as Map<String, Object?>;
  final packages = packageConfig['packages'];

  if (packages is! List<Object?>) {
    throw StateError('package_config.json is missing the packages list.');
  }

  for (final entry in packages) {
    if (entry is! Map<String, Object?>) {
      continue;
    }

    if (entry['name'] != packageName) {
      continue;
    }

    final rootUriValue = entry['rootUri'];

    if (rootUriValue is! String) {
      throw StateError('Package $packageName is missing a rootUri value.');
    }

    final rootUri = Uri.parse(rootUriValue);
    return packageConfigFile.uri.resolveUri(rootUri).toFilePath();
  }

  throw StateError('Package $packageName was not found in package_config.json');
}

Future<String> _resolveSqliteWasmSource(String driftRoot) async {
  final preferredSource = File(
    p.join(driftRoot, 'extension', 'devtools', 'build', 'sqlite3.wasm'),
  );

  if (preferredSource.existsSync()) {
    return preferredSource.path;
  }

  await for (final entity in Directory(driftRoot).list(recursive: true)) {
    if (entity is! File) {
      continue;
    }

    if (p.basename(entity.path) != DbConstants.webSqliteWasmFileName) {
      continue;
    }

    return entity.path;
  }

  throw StateError('Could not locate sqlite3.wasm inside the drift package.');
}
