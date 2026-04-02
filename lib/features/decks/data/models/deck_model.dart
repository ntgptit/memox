import 'package:isar/isar.dart';

part 'deck_model.g.dart';

@collection
class DeckModel {
  DeckModel({this.id = Isar.autoIncrement, this.name = ''});

  Id id;
  String name;
}
