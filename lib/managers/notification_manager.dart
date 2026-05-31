import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '/app_keys.dart';
import '/managers/abstract_notification_manager.dart';
import '/managers/mock_notification_manager.dart';
import '/managers/login_manager.dart';
import '/api/api_client.dart';
import '/models/rental_item.dart';
import '/screens/item_detail_screen.dart';

const String _kNotificationPortName = 'notification_tap_port';

// 앱이 백그라운드일 때 알림 탭 처리 — 별도 isolate에서 실행되므로 top-level 필수.
@pragma('vm:entry-point')
void _onNotificationBackgroundTap(NotificationResponse response) {
  IsolateNameServer.lookupPortByName(_kNotificationPortName)
      ?.send(response.payload);
}

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
  final ReceivePort _port = ReceivePort();

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
      // 백그라운드 탭 콜백을 메인 isolate로 전달하기 위한 포트 등록
      IsolateNameServer.registerPortWithName(_port.sendPort, _kNotificationPortName);
      _port.listen((payload) {
        if (payload is String) {
          log('🔔 알림 탭 감지 (background) — payload: $payload');
          _handleNotificationClick(jsonDecode(payload));
        }
      });
      await _setupLocalNotifications();
      await _setupMessageHandlers();
      _messaging.onTokenRefresh.listen(_syncTokenToServer);
    }
  }

  @override
  Future<void> updateDeviceTokenToServer() async {
    if (!LoginManager().isLoggedIn) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _messaging.getAPNSToken();
    }
    final String? token = await _messaging.getToken();
    if (token != null) {
      await _syncTokenToServer(token);
    }
  }

  Future<void> _syncTokenToServer(String token) async {
    if (!LoginManager().isLoggedIn) return;
    try {
      await _apiClient.dio.patch(
        '/api/v1/users/me/device-token',
        data: {'fcmToken': token},
        options: Options(
          headers: {'Authorization': 'Bearer ${LoginManager().accessToken}'},
        ),
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
        log('🔔 알림 탭 감지 (foreground) — payload: ${res.payload}');
        if (res.payload != null) {
          _handleNotificationClick(jsonDecode(res.payload!));
        }
      },
      onDidReceiveBackgroundNotificationResponse: _onNotificationBackgroundTap,
    );
  }

  // 종료 상태에서 알림 클릭으로 앱 실행 시 처리.
  // main()에서 getInitialMessage()를 미리 호출하고 itemId만 전달받는다.
  @override
  Future<void> handleInitialMessage(String? itemId) async {
    if (itemId == null) return;
    await _handleNotificationClick({
      'type': 'RENTAL_REQUEST',
      'requestId': itemId,
    });
  }

  Future<void> _setupMessageHandlers() async {
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
            'urgent_rental_channel',
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
    log('🔔 _handleNotificationClick — type: $type, data: $data');
    if (type == 'RENTAL_REQUEST') {
      final String? requestId = data['requestId']?.toString();
      if (requestId == null) return;
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) =>
              ItemDetailScreen(item: RentalItem.placeholder(requestId)),
        ),
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
