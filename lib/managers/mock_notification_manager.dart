import 'dart:developer';
import '/managers/abstract_notification_manager.dart';

AbstractNotificationManager createManager() => MockNotificationManager();

class MockNotificationManager extends AbstractNotificationManager {
  static final MockNotificationManager _instance =
      MockNotificationManager._internal();
  factory MockNotificationManager() => _instance;
  MockNotificationManager._internal();

  @override
  Future<void> initialize() async {
    log('알림 매니저 초기화 (알림 미지원)');
  }

  @override
  Future<void> updateDeviceTokenToServer() async {
    log('이 환경에서는 기기 토큰 업데이트를 지원하지 않습니다');
  }

  @override
  Future<void> handleInitialMessage() async {}

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    log('📢 웹 알림 수신: $title — $body');
  }
}
