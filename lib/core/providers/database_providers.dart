import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/database/db_initializer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isar(Ref ref) async {
  final isarInstance = await const DbInitializer().open();
  ref.onDispose(isarInstance.close);
  return isarInstance;
}
