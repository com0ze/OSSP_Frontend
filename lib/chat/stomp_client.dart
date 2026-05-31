import 'dart:convert';
import 'dart:developer';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '/chat/abstract_stomp_client.dart';
import '/managers/login_manager.dart';
import '/models/chat.dart';

AbstractStompClient createStompClient() => ChatStompClient();

class ChatStompClient extends AbstractStompClient {
  static final ChatStompClient _instance = ChatStompClient._internal();
  factory ChatStompClient() => _instance;
  ChatStompClient._internal();

  static const _baseUrl = 'ws://168.110.102.12:8080';

  // ⚠️ 백엔드의 실제 WebSocket 등록 경로로 수정 필요 (Spring: 보통 /ws 또는 /stomp)
  static const _wsPath = '/ws-stomp';

  StompClient? _client;
  final Map<String, void Function()> _subscriptions = {};
  final Map<String, void Function(Chat)> _pendingSubscriptions = {};

  @override
  bool get isConnected => _client?.connected ?? false;

  // ── 연결 ────────────────────────────────────────────────────────────────────

  @override
  void connect() {
    if (isConnected) return;
    final token = LoginManager().accessToken;
    _client = StompClient(
      config: StompConfig(
        url: '$_baseUrl$_wsPath',
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        onConnect: _onConnect,
        onWebSocketError: (error) => log('❌ STOMP WebSocket 오류: $error'),
        onStompError: (frame) => log('❌ STOMP 프로토콜 오류: ${frame.body}'),
        onDisconnect: (_) => log('🔌 STOMP 연결 해제'),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );
    _client!.activate();
    log('🔌 STOMP 연결 시도: $_baseUrl$_wsPath');
  }

  @override
  void disconnect() {
    _subscriptions.clear();
    _pendingSubscriptions.clear();
    _client?.deactivate();
    _client = null;
    log('🔌 STOMP 연결 종료');
  }

  void _onConnect(StompFrame frame) {
    log('✅ STOMP 연결 성공');
    for (final entry in _pendingSubscriptions.entries) {
      _doSubscribe(entry.key, entry.value);
    }
    _pendingSubscriptions.clear();
  }

  // ── 구독 ────────────────────────────────────────────────────────────────────

  // 채팅방 메시지 수신 구독. 이미 구독 중이면 재구독.
  // 연결 전 호출 시 pending으로 등록 후 연결 완료 시 자동 구독.
  @override
  void subscribeToRoom(String roomId, void Function(Chat message) onMessage) {
    _subscriptions[roomId]?.call();

    if (!isConnected) {
      _pendingSubscriptions[roomId] = onMessage;
      log('⏳ STOMP 미연결 — 구독 예약: $roomId');
      return;
    }

    _doSubscribe(roomId, onMessage);
  }

  void _doSubscribe(String roomId, void Function(Chat) onMessage) {
    final unsubscribe = _client!.subscribe(
      destination: '/topic/rooms/$roomId',
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final data = jsonDecode(frame.body!) as Map<String, dynamic>;
          onMessage(Chat.fromJson(data));
        } catch (e) {
          log('❌ STOMP 메시지 파싱 오류: $e');
        }
      },
    );
    _subscriptions[roomId] = unsubscribe;
    log('📩 채팅방 구독: $roomId');
  }

  @override
  void unsubscribeFromRoom(String roomId) {
    _subscriptions[roomId]?.call();
    _subscriptions.remove(roomId);
    _pendingSubscriptions.remove(roomId);
    log('📩 채팅방 구독 해제: $roomId');
  }

  // ── 전송 ────────────────────────────────────────────────────────────────────

  @override
  void sendMessage({
    required String roomId,
    required String senderId,
    required String content,
  }) {
    if (!isConnected) {
      log('⚠️ STOMP 미연결 상태 — 전송 불가');
      return;
    }
    _client!.send(
      destination: '/app/chat.send',
      body: jsonEncode({
        'roomId': roomId,
        'senderId': senderId,
        'content': content,
      }),
    );
  }
}
