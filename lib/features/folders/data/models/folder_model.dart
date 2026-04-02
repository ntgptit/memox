import 'package:isar/isar.dart';

part 'folder_model.g.dart';

@collection
class FolderModel {
  FolderModel({this.id = Isar.autoIncrement, this.name = ''});

  Id id;
  String name;
}
