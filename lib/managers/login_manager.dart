import '../models/main_user.dart';

class LoginManager {
  static final LoginManager _instance = LoginManager._internal();

  factory LoginManager() {
    return _instance;
  }

  LoginManager._internal();

  MainUser? _currentUser;
  String? _authToken;

  MainUser? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoggedIn => _currentUser != null && _authToken != null;

  Future<bool> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      _authToken = 'sample_token_${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = MainUser(
        id: '1',
        name: 'Sample User',
        email: email,
        mannerScore: 85,
        personalInformation: 'Sample user information',
      );

      return true;
    } catch (e) {
      return false;
    }
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
        mannerScore: 50,
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
