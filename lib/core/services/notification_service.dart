abstract interface class NotificationService {
  Future<void> initialize();

  Future<void> show({
    required String title,
    required String body,
  });
}

final class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> show({
    required String title,
    required String body,
  }) async {}
}
