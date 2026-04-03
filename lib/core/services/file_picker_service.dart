import 'dart:convert';

import 'package:file_picker/file_picker.dart';

typedef PickedTextFile = ({String fileName, String content});

abstract interface class FilePickerService {
  Future<PickedTextFile?> pickTextFile({
    required List<String> allowedExtensions,
  });
}

final class PlatformFilePickerService implements FilePickerService {
  const PlatformFilePickerService();

  @override
  Future<PickedTextFile?> pickTextFile({
    required List<String> allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    final bytes = file.bytes;

    if (bytes == null) {
      return null;
    }

    return (fileName: file.name, content: utf8.decode(bytes));
  }
}

final class NoopFilePickerService implements FilePickerService {
  const NoopFilePickerService();

  @override
  Future<PickedTextFile?> pickTextFile({
    required List<String> allowedExtensions,
  }) async => null;
}
