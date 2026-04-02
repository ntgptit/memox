import 'package:isar/isar.dart';

part 'flashcard_model.g.dart';

@collection
class FlashcardModel {
  FlashcardModel({
    this.id = Isar.autoIncrement,
    this.front = '',
    this.back = '',
  });

  Id id;
  String front;
  String back;
}
