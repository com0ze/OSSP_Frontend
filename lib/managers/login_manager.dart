import 'package:open_source_software/api/api_client.dart';
import 'package:open_source_software/managers/token_storage_manager.dart';
import 'package:open_source_software/models/main_user.dart';
import 'package:open_source_software/models/user.dart';

class LoginManager {
  static final LoginManager _instance = LoginManager._internal();

  factory LoginManager() => _instance;
  LoginManager._internal();

  static void Function(String message)? _forceLogoutHandler;

  static void setForceLogoutHandler(void Function(String message) handler) {
    _forceLogoutHandler = handler;
  }

  bool _isLoggingOut = false;

  Future<void> forceLogout(String message) async {
    if (_isLoggingOut || !isLoggedIn) return;
    _isLoggingOut = true;
    await logout();
    _isLoggingOut = false;
    _forceLogoutHandler?.call(message);
  }

  final _tokenStorage = TokenStorageManager();

  MainUser? _currentUser;
  User notLoginStateUser = User(id: 'guest', name: 'Guest', email: '', score: 0);

  String? _accessToken;
  MainUser? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isLoggedIn => _currentUser != null && _accessToken != null;

  User get currentUserOrGuest => _currentUser ?? notLoginStateUser;

  void updateUser(MainUser user) => _currentUser = user;

  void updateCurrentBuilding(String? building) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(currentBuilding: building);
  }

  // ── 내 프로필 조회 ─────────────────────────────────────────
  Future<MainUser?> _fetchMe() async {
    final res = await ApiClient.dio.get('/api/v1/users/me');
    final data = res.data['data'] as Map<String, dynamic>;
    return MainUser(
      id: data['userId'].toString(),
      name: data['nickname'] as String,
      email: data['email'] as String? ?? '',
      score: (data['mannerScore'] as num?)?.toDouble() ?? 0.0,
      currentBuilding: data['currentBuilding'] as String?,
      personalInformation: '',
    );
  }

  // ── 자동 로그인 ────────────────────────────────────────────
  Future<void> initAutoLogin() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null) return;

    try {
      _accessToken = token;
      _currentUser = await _fetchMe();
    } catch (_) {
      _accessToken = null;
      await _tokenStorage.clearSessionTokens();
    }
  }

  // ── 로그인 ─────────────────────────────────────────────────
  // auth 엔드포인트는 공통 래퍼 없이 직접 반환
  Future<bool> login(String email, String password) async {
    try {
      final res = await ApiClient.dio.post(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );

      final newAccessToken = res.data['accessToken'] as String;
      final newRefreshToken = res.data['refreshToken'] as String;

      _accessToken = newAccessToken;
      await _tokenStorage.saveTokens(newAccessToken, newRefreshToken);

      _currentUser = await _fetchMe();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── 로그아웃 ───────────────────────────────────────────────
  // 서버 로그아웃 엔드포인트 없음 — 로컬 토큰만 파기
  Future<void> logout() async {
    _currentUser = null;
    _accessToken = null;
    await _tokenStorage.clearSessionTokens();
  }

  // ── 회원가입 ───────────────────────────────────────────────
  // 201 응답은 body 없음 → 가입 후 자동 로그인
  Future<bool> register(String name, String email, String password) async {
    try {
      await ApiClient.dio.post(
        '/api/v1/auth/signup',
        data: {'email': email, 'password': password, 'nickname': name},
      );
      // 가입 성공 → 바로 로그인
      return await login(email, password);
    } catch (_) {
      return false;
    }
  }

  // ── 유효성 검사 ────────────────────────────────────────────
  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) return '이메일을 입력해주세요.';

    final emailFormatRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailFormatRegex.hasMatch(email)) return '올바른 이메일 형식이 아닙니다.';

    final allowedDomains = ['dgu.ac.kr', 'dongguk.edu'];
    final domain = email.split('@').last;
    if (!allowedDomains.contains(domain)) {
      return '허용되지 않은 이메일 도메인입니다.\n가능한 이메일 도메인: @dgu.ac.kr, @dongguk.edu';
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) return '비밀번호를 입력해주세요.';
    if (password.length < 8 || password.length > 15) {
      return '비밀번호는 8~15자 사이여야 합니다.';
    }
    final invalidCharRegex = RegExp(r'[^a-zA-Z\d!@#$%^&*]');
    if (invalidCharRegex.hasMatch(password)) return '허용되지 않는 특수문자가 포함되어 있습니다.';

    List<String> errors = [];
    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) errors.add('소문자를 하나 이상 포함해야 합니다.');
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) errors.add('대문자를 하나 이상 포함해야 합니다.');
    if (!RegExp(r'(?=.*\d)').hasMatch(password)) errors.add('숫자를 하나 이상 포함해야 합니다.');
    if (!RegExp(r'(?=.*[!@#$%^&*])').hasMatch(password)) {
      errors.add('특수문자(!@#\$%^&*)를 하나 이상 포함해야 합니다.');
    }
    if (errors.isNotEmpty) return errors.join('\n');
    return null;
  }
}
