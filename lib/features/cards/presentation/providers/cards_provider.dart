import 'package:memox/core/constants/app_strings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cards_provider.g.dart';

@riverpod
String cardsScreenTitle(CardsScreenTitleRef ref) => AppStrings.cardsTitle;
