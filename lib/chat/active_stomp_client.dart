import '/chat/abstract_stomp_client.dart';
// import '/chat/mock_stomp_client.dart'
//     if (dart.library.io) '/chat/stomp_client.dart'
//     as platform_impl;
import '/chat/stomp_client.dart' as platform_impl;

AbstractStompClient get activeStompClient => platform_impl.createStompClient();
