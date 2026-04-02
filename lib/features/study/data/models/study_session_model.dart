import 'package:isar/isar.dart';

part 'study_session_model.g.dart';

@collection
class StudySessionModel {
  StudySessionModel({this.id = Isar.autoIncrement, this.mode = ''});

  Id id;
  String mode;
}
