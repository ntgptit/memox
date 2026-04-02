import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app.dart';
import 'package:memox/bootstrap.dart';

Future<void> main() async {
  await bootstrap();
  runApp(const ProviderScope(child: MemoxApp()));
}
