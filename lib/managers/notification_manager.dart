import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '/app_keys.dart';
import '/managers/abstract_notification_manager.dart';
import '/managers/mock_notification_manager.dart';
import '/managers/data_manager.dart';
import '/api/api_client.dart';
import '/screens/item_detail_screen.dart';

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
      await _setupMessageHandlers();
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
        data: {'deviceToken': token},
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

  Future<void> _setupMessageHandlers() async {
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage.data);
    }

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification == null) return;
      final type = message.data['type'] as String?;
      _localNotifications.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        _notificationDetails(type),
        payload: jsonEncode(message.data),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationClick(message.data);
    });
  }

  NotificationDetails _notificationDetails(String? type) {
    switch (type) {
      case 'RENTAL_REQUEST':
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            'rental_request_channel',
            '대여 요청 알림',
            channelDescription: '새로운 대여 요청 알림',
            importance: Importance.max,
            priority: Priority.high,
            color: Color(0xFF2196F3),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        );
      default:
        return const NotificationDetails(
          android: AndroidNotificationDetails(
            'urgent_rental_channel',
            '긴급 알림',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        );
    }
  }

  Future<void> _handleNotificationClick(Map<String, dynamic> data) async {
    final String? type = data['type'];
    if (type == 'RENTAL_REQUEST') {
      final String? requestId = data['requestId']?.toString();
      if (requestId == null) return;
      final item = await DataManager().getRentalItem(requestId);
      if (item == null) return;
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
      );
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
