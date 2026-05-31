import 'dart:developer';
import '/api/api_client.dart';
import '/chat/abstract_stomp_client.dart';
import '/models/chat.dart';

AbstractStompClient createStompClient() => MockStompClient();

class MockStompClient extends AbstractStompClient {
  static final MockStompClient _instance = MockStompClient._internal();
  factory MockStompClient() => _instance;
  MockStompClient._internal();

  bool _connected = false;
  final Map<String, void Function(Chat)> _roomCallbacks = {};

  @override
  bool get isConnected => _connected;

  @override
  void connect() {
    _connected = true;
    log('🔌 [Mock] STOMP 연결 성공');
  }

  @override
  void disconnect() {
    _connected = false;
    _roomCallbacks.clear();
    log('🔌 [Mock] STOMP 연결 종료');
  }

  @override
  void subscribeToRoom(String roomId, void Function(Chat message) onMessage) {
    _roomCallbacks[roomId] = onMessage;
    log('📩 [Mock] 채팅방 구독: $roomId');
  }

  @override
  void unsubscribeFromRoom(String roomId) {
    _roomCallbacks.remove(roomId);
    log('📩 [Mock] 채팅방 구독 해제: $roomId');
  }

  @override
  void sendMessage({
    required String roomId,
    required String senderId,
    required String content,
  }) {
    final chat = Chat(
      senderId: senderId,
      content: content,
      createdAt: DateTime.now(),
    );
    // mock 서버 REST fallback으로 메시지 저장
    ApiClient().dio.post(
      '/api/v1/chats/$roomId/messages',
      data: chat.toJson(),
    );
    // 구독 콜백에 즉시 에코 — 실제 STOMP 브로드캐스트 흉내
    _roomCallbacks[roomId]?.call(chat);
    log('📤 [Mock] 메시지 전송: $roomId — $content');
  }
}
