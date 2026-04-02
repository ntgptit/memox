import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@Riverpod(keepAlive: true)
bool connectivity(Ref ref) => true;
