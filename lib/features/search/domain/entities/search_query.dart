import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_query.freezed.dart';
part 'search_query.g.dart';

@freezed
abstract class SearchQuery with _$SearchQuery {

  const factory SearchQuery({required String value}) = _SearchQuery;
  const SearchQuery._();

  factory SearchQuery.fromJson(Map<String, dynamic> json) =>
      _$SearchQueryFromJson(json);

  bool get isEmpty => value.isEmpty;
}
