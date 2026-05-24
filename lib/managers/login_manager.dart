import '/api/api_client.dart';
import '/managers/token_storage_manager.dart';
import '/models/main_user.dart';
import '/models/user.dart';

class LoginManager {
  static final LoginManager _instance = LoginManager._internal();

  factory LoginManager() {
    return _instance;
  }

  LoginManager._internal();

  static void Function(String message)? _forceLogoutHandler;

  static void setForceLogoutHandler(void Function(String message) handler) {
    _forceLogoutHandler = handler;
  }

  bool _isLoggingOut = false;

  Future<void> forceLogout(String message) async {
    // 동시에 여러 곳에서 forceLogout이 호출되어도 한 번만 실행
    if (_isLoggingOut || !isLoggedIn) return;
    _isLoggingOut = true;
    await logout();
    _isLoggingOut = false;
    _forceLogoutHandler?.call(message);
  }

  final _tokenStorage = TokenStorageManager();

  MainUser? _currentUser;
  User notLoginStateUser = User(
    id: 'guest',
    name: 'Guest',
    email: '',
    score: 0,
  );

  String? _accessToken;
  MainUser? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isLoggedIn => _currentUser != null && _accessToken != null;
  ApiClient apiClient = ApiClient();

  User get currentUserOrGuest {
    return _currentUser ?? notLoginStateUser;
  }

  void updateUser(MainUser user) {
    _currentUser = user;
  }

  // ⭐️ 3. 앱 시작 시 자동 로그인을 위한 초기화 함수
  Future<void> initAutoLogin() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null) return;

    try {
      final res = await apiClient.dio.get('/api/v1/auth/me');
      _accessToken = token;
      _currentUser = MainUser(
        id: res.data['id'].toString(),
        name: res.data['name'] as String,
        email: res.data['email'] as String,
        score: (res.data['score'] as num).toDouble(),
        personalInformation: res.data['personalInformation'] as String? ?? '',
      );
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

      final newAccessToken = res.data['accessToken'] as String;
      final newRefreshToken = res.data['refreshToken'] as String;

      _accessToken = newAccessToken;
      await _tokenStorage.saveTokens(newAccessToken, newRefreshToken);

      // TODO: 로그인 응답에 유저 정보가 포함되면 파싱 필요
      _currentUser = MainUser(
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

  Future<void> logout() async {
    try {
      await apiClient.dio.post('/api/v1/auth/logout');
    } catch (_) {
      // 서버 요청 실패해도 로컬 상태는 반드시 초기화
    }

    _currentUser = null;
    _accessToken = null;
    await _tokenStorage.clearSessionTokens();
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final res = await apiClient.dio.post(
        '/api/v1/auth/signup',
        data: {'nickname': name, 'email': email, 'password': password},
      );

      final newAccessToken = res.data['accessToken'] as String;
      final newRefreshToken = res.data['refreshToken'] as String;

      _accessToken = newAccessToken;
      await _tokenStorage.saveTokens(newAccessToken, newRefreshToken);

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

  String? validateEmail(String? email) {
    // 0. 빈 값 확인
    if (email == null || email.isEmpty) {
      return '이메일을 입력해주세요.';
    }

    // 1. 이메일 형식 확인 (정규표현식)
    // [영문/숫자/특수문자]@[영문/숫자].[영문] 형태인지 체크
    final emailFormatRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailFormatRegex.hasMatch(email)) {
      return '올바른 이메일 형식이 아닙니다.';
    }

    // 2. 이메일 도메인 확인
    final allowedDomains = ['dgu.ac.kr', 'dongguk.edu'];
    final domain = email.split('@').last;

    if (!allowedDomains.contains(domain)) {
      return '허용되지 않은 이메일 도메인입니다.\n가능한 이메일 도메인: @dgu.ac.kr, @dongguk.edu';
    }

    // 모든 검사 통과 시 null 반환 (에러 없음)
    return null;
  }

  String? validatePassword(String? password) {
    // 0. 빈 값 확인
    if (password == null || password.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }

    // 1. 길이 검사 (8~15자)
    if (password.length < 8 || password.length > 15) {
      return '비밀번호는 8~15자 사이여야 합니다.';
    }

    // 2. 허용되지 않는 특수문자 검사
    // [a-zA-Z0-9!@#$%^&*] 이외의 문자가 하나라도 있으면 실패
    final invalidCharRegex = RegExp(r'[^a-zA-Z\d!@#$%^&*]');
    if (invalidCharRegex.hasMatch(password)) {
      return '허용되지 않는 특수문자가 포함되어 있습니다.';
    }

    // 3. 필수 포함 요소 검사 (대문자, 소문자, 숫자, 특수문자)
    List<String> errors = [];
    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
      errors.add('소문자를 하나 이상 포함해야 합니다.');
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
      errors.add('대문자를 하나 이상 포함해야 합니다.');
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
      errors.add('숫자를 하나 이상 포함해야 합니다.');
    }
    if (!RegExp(r'(?=.*[!@#$%^&*])').hasMatch(password)) {
      errors.add('특수문자(!@#\$%^&*)를 하나 이상 포함해야 합니다.');
    }
    if (errors.isNotEmpty) return errors.join('\n');

    // 모든 검사 통과 시 null 반환 (에러 없음)
    return null;
  }
}
