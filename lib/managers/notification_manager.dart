import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '/managers/abstract_notification_manager.dart';
import '/managers/mock_notification_manager.dart';
import '/api/api_client.dart';

AbstractNotificationManager createManager() {
  if (defaultTargetPlatform == TargetPlatform.windows) {
    return MockNotificationManager(); // 윈도우에서는 안전하게 가짜로 구동!
  }
  return NotificationManager(); // 안드로이드, iOS 모바일 기기일 때만 진짜 파이어베이스 가동
}

class NotificationManager extends AbstractNotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiClient _apiClient = ApiClient();

  @override
  Future<void> initialize() async {
    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _setupLocalNotifications();
      _setupMessageHandlers();
      _messaging.onTokenRefresh.listen(_syncTokenToServer);
    }
  }

  @override
  Future<void> updateDeviceTokenToServer() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _messaging.getAPNSToken();
    }
    final String? token = await _messaging.getToken();
    if (token != null) {
      await _syncTokenToServer(token);
    }
  }

  Future<void> _syncTokenToServer(String token) async {
    try {
      await _apiClient.dio.patch(
        '/api/v1/users/me/device-token',
        data: {'fcmToken': token},
      );
      log('✅ 서버에 기기 토큰 갱신 성공');
    } catch (e) {
      log('❌ 기기 토큰 서버 동기화 실패: $e');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (res) {
        if (res.payload != null) {
          _handleNotificationClick(jsonDecode(res.payload!));
        }
      },
    );
  }

  void _setupMessageHandlers() async {
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage.data);
    }

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification == null) return;
      _localNotifications.show(
        message.notification.hashCode,
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'urgent_rental_channel',
            '긴급 알림',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true, // ⭐️ 포그라운드에서 알림 배너 표시
            presentSound: true, // ⭐️ 알림 소리 재생
            presentBadge: true, // ⭐️ 앱 아이콘 배지 표시
          ),
        ),
        payload: jsonEncode(message.data),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationClick(message.data);
    });
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    final String? type = data['type'];
    if (type == 'RENTAL_REQUEST') {
      log('🔗 라우팅: 대여 상세로 이동 (ID: ${data['requestId']})');
    } else if (type == 'CHAT_MESSAGE') {
      log('🔗 라우팅: 채팅방으로 이동 (ID: ${data['roomId']})');
    }
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'urgent_rental_channel',
          '긴급 알림',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true, // ⭐️ 포그라운드에서 알림 배너 표시
          presentSound: true, // ⭐️ 알림 소리 재생
          presentBadge: true, // ⭐️ 앱 아이콘 배지 표시
        ),
      ),
      payload: payload,
    );
  }
}
