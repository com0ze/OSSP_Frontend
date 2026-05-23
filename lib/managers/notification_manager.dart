import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_manager.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final ApiManager _apiManager = ApiManager();

  Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true, badge: true, sound: true, provisional: true, 
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _setupLocalNotifications();
      _setupMessageHandlers();

      _messaging.onTokenRefresh.listen((newToken) {
        _syncTokenToServer(newToken);
      });
    }
  }

  Future<void> updateDeviceTokenToServer() async {
    if (Platform.isIOS) {
      await _messaging.getAPNSToken();
    }
    String? token = await _messaging.getToken();
    if (token != null) {
      await _syncTokenToServer(token);
    }
  }

  Future<void> _syncTokenToServer(String token) async {
    try {
      await _apiManager.dio.patch(
        '/api/v1/users/me/device-token',
        data: {'fcmToken': token},
      );
      print('✅ 서버에 기기 토큰 갱신 성공');
    } catch (e) {
      print('❌ 기기 토큰 서버 동기화 실패: $e');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const initSettings = InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'));
    await _localNotifications.initialize(initSettings, onDidReceiveNotificationResponse: (res) {
      if (res.payload != null) {
        _handleNotificationClick(jsonDecode(res.payload!));
      }
    });
  }

  void _setupMessageHandlers() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage.data);
    }

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        _localNotifications.show(
          message.notification.hashCode, message.notification!.title, message.notification!.body,
          const NotificationDetails(android: AndroidNotificationDetails('urgent_rental_channel', '긴급 알림', importance: Importance.max, priority: Priority.high)),
          payload: jsonEncode(message.data),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationClick(message.data);
    });
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    final String? type = data['type'];
    if (type == 'RENTAL_REQUEST') {
      print('🔗 라우팅: 대여 상세로 이동 (ID: ${data['requestId']})');
    } else if (type == 'CHAT_MESSAGE') {
      print('🔗 라우팅: 채팅방으로 이동 (ID: ${data['roomId']})');
    }
  }

  // 💡 [여기부터 추가!] 테스트 버튼이 호출할 수동 알림 발생 함수입니다.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'urgent_rental_channel', // 채널 ID
      '긴급 알림', // 채널 이름
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(id, title, body, platformDetails, payload: payload);
  }
 } // 👈 원래 있던 맨 마지막 닫는 중괄호
