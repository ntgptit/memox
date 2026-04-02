abstract interface class ShareService {
  Future<void> shareText(String value);
}

final class NoopShareService implements ShareService {
  const NoopShareService();

  @override
  Future<void> shareText(String value) async {}
}
