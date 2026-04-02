import 'package:memox/core/constants/app_strings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'decks_provider.g.dart';

@riverpod
String decksScreenTitle(DecksScreenTitleRef ref) => AppStrings.decksTitle;
