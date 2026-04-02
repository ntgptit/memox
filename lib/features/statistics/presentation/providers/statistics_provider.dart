import 'package:memox/core/constants/app_strings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'statistics_provider.g.dart';

@riverpod
String statisticsScreenTitle(Ref ref) => AppStrings.statisticsTitle;
