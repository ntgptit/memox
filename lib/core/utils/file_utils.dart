import 'dart:io';

mixin AppFileUtils {
  static Future<String> readText(File file) => file.readAsString();

  static Future<void> writeText(File file, String value) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(value);
  }
}
