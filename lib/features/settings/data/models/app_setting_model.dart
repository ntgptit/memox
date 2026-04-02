import 'package:isar/isar.dart';

part 'app_setting_model.g.dart';

@collection
class AppSettingModel {
  AppSettingModel({
    this.id = Isar.autoIncrement,
    this.key = '',
    this.value = '',
  });

  Id id;
  String key;
  String value;
}
