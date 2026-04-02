abstract interface class FilePickerService {
  Future<String?> pickFilePath();
}

final class NoopFilePickerService implements FilePickerService {
  const NoopFilePickerService();

  @override
  Future<String?> pickFilePath() async => null;
}
