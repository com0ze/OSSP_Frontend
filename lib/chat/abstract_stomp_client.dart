import '/models/chat.dart';

abstract class AbstractStompClient {
  bool get isConnected;
  void connect();
  void disconnect();
  void subscribeToRoom(String roomId, void Function(Chat message) onMessage);
  void unsubscribeFromRoom(String roomId);
  void sendMessage({
    required String roomId,
    required String senderId,
    required String content,
  });
}
