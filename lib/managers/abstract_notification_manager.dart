abstract class AbstractNotificationManager {
  Future<void> initialize();
  Future<void> updateDeviceTokenToServer();
  Future<void> handleInitialMessage();
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  });
}
