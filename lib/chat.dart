import 'package:open_source_software/user.dart';

class Chat {
  final User _sendUser;
  final String _chatContent;
  final DateTime _sendTime;

  Chat(this._sendUser, this._chatContent, this._sendTime);

  User get sendUser => _sendUser;
  String get chatContent => _chatContent;
  DateTime get sendTime => _sendTime;
}
