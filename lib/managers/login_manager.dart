import '/api/api_client.dart';
import '/managers/token_storage_manager.dart';
import '/managers/data_manager.dart';
import '/models/main_user.dart';

// user와 accessToken을 묶어 원자적으로 관리한다.
// null = 비로그인, non-null = 로그인 상태.
// 로그아웃 후 재로그인은 새 _Session으로 교체하므로 문제없음.
class _Session {
  final MainUser user;
  final String accessToken;

  const _Session({required this.user, required this.accessToken});

  _Session copyWithUser(MainUser newUser) =>
      _Session(user: newUser, accessToken: accessToken);
}

class LoginManager {
  static final LoginManager _instance = LoginManager._internal();
  factory LoginManager() => _instance;
  LoginManager._internal();

  static void Function(String message)? _forceLogoutHandler;
  static void setForceLogoutHandler(void Function(String message) handler) {
    _forceLogoutHandler = handler;
  }

  final _tokenStorage = TokenStorageManager();
  final ApiClient apiClient = ApiClient();

  _Session? _session;
  bool _isLoggingOut = false;

  bool get isLoggedIn => _session != null;

  // 로그인 상태에서만 호출해야 함. 비로그인 시 StateError 발생.
  MainUser get currentUser {
    final s = _session;
    if (s == null) throw StateError('currentUser accessed while not logged in');
    return s.user;
  }

  String get accessToken {
    final s = _session;
    if (s == null) throw StateError('accessToken accessed while not logged in');
    return s.accessToken;
  }

  void updateUser(MainUser user) {
    final s = _session;
    if (s == null) return;
    _session = s.copyWithUser(user);
  }

  Future<void> updateDutyStatus(bool isOnDuty) async {
    await apiClient.dio.patch(
      '/api/v1/users/me/duty',
      data: {'isOnDuty': isOnDuty},
    );
    final s = _session;
    if (s == null) return;
    _session = s.copyWithUser(s.user.copyWith(isOnDuty: isOnDuty));
  }

  Future<void> forceLogout(String message) async {
    if (_isLoggingOut || !isLoggedIn) return;
    _isLoggingOut = true;
    await logout();
    _isLoggingOut = false;
    _forceLogoutHandler?.call(message);
  }

  // 앱 시작 시 저장된 토큰으로 자동 로그인
  Future<void> initAutoLogin() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null) return;

    try {
      final res = await apiClient.dio.get('/api/v1/users/me');
      _session = _Session(
        user: MainUser.fromJson(res.data as Map<String, dynamic>),
        accessToken: token,
      );
      DataManager().updateMainUser();
    } catch (_) {
      await _tokenStorage.clearSessionTokens();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final res = await apiClient.dio.post(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );
      await _tokenStorage.saveTokens(
        res.data['accessToken'] as String,
        res.data['refreshToken'] as String,
      );
      await initAutoLogin();
      return isLoggedIn;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    _session = null;
    await _tokenStorage.clearSessionTokens();
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      await apiClient.dio.post(
        '/api/v1/auth/signup',
        data: {'nickname': name, 'email': email, 'password': password},
      );
      return await login(email, password);
    } catch (_) {
      return false;
    }
  }

  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return '이메일을 입력해주세요.';
    }

    final emailFormatRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailFormatRegex.hasMatch(email)) {
      return '올바른 이메일 형식이 아닙니다.';
    }

    final allowedDomains = ['dgu.ac.kr'];
    final domain = email.split('@').last;
    if (!allowedDomains.contains(domain)) {
      return '허용되지 않은 이메일 도메인입니다.\n가능한 이메일 도메인: @dgu.ac.kr';
    }

    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }

    if (password.length < 8 || password.length > 15) {
      return '비밀번호는 8~15자 사이여야 합니다.';
    }

    final invalidCharRegex = RegExp(r'[^a-zA-Z\d!@#$%^&*]');
    if (invalidCharRegex.hasMatch(password)) {
      return '허용되지 않는 특수문자가 포함되어 있습니다.';
    }

    return null;
  }
}
