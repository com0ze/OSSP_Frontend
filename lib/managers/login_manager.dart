import 'package:open_source_software/models/main_user.dart';
import 'package:open_source_software/models/user.dart';

class LoginManager {
  static final LoginManager _instance = LoginManager._internal();

  factory LoginManager() {
    return _instance;
  }

  LoginManager._internal();

  MainUser? _currentUser;
  User notLoginStateUser = User(
    id: 'guest',
    name: 'Guest',
    email: '',
    score: 0,
  );
  String? _authToken;

  MainUser? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoggedIn => _currentUser != null && _authToken != null;

  Future<bool> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      _authToken = 'sample_token_${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = MainUser(
        // TODO: 실제 로그인 한 걸로 만들어야함
        id: '0',
        name: 'Kim sample',
        email: email,
        score: 10.0,
        personalInformation: 'Sample user information',
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  User get currentUserOrGuest {
    return _currentUser ?? notLoginStateUser;
  }

  Future<void> logout() async {
    _currentUser = null;
    _authToken = null;
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      _authToken = 'sample_token_${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = MainUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        score: 50,
        personalInformation: '',
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  void updateUser(MainUser user) {
    _currentUser = user;
  }

  Future<bool> refreshToken() async {
    if (_authToken == null) return false;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _authToken = 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}';
      return true;
    } catch (e) {
      return false;
    }
  }
}
