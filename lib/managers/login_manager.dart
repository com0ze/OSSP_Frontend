import 'package:open_source_software/api/api_client.dart';
import 'package:open_source_software/managers/token_storage_manager.dart';
import 'package:open_source_software/models/main_user.dart';
import 'package:open_source_software/models/user.dart';

class LoginManager {
  static final LoginManager _instance = LoginManager._internal();

  factory LoginManager() {
    return _instance;
  }

  LoginManager._internal();

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

  User get currentUserOrGuest {
    return _currentUser ?? notLoginStateUser;
  }

  void updateUser(MainUser user) {
    _currentUser = user;
  }

  // ⭐️ 3. 앱 시작 시 자동 로그인을 위한 초기화 함수
  Future<void> initAutoLogin() async {
    // 기기에 저장된 액세스 토큰이 있는지 확인
    final token = await _tokenStorage.getAccessToken();
    if (token == null) return;

    try {
      // AuthInterceptor가 저장소에서 토큰을 자동으로 헤더에 추가함
      final res = await ApiClient.dio.get('/me');

      _accessToken = token;
      // TODO: 실제 서버 응답 구조에 맞게 파싱 필요
      _currentUser = MainUser(
        id: res.data['id'] as String,
        name: res.data['name'] as String,
        email: res.data['email'] as String,
        score: (res.data['score'] as num).toDouble(),
        personalInformation:
            res.data['personal_information'] as String? ?? '',
      );
    } catch (_) {
      // 토큰 갱신도 실패한 경우 → 저장된 토큰 파기 후 로그인 화면으로
      await _tokenStorage.clearSessionTokens();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final res = await ApiClient.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final newAccessToken = res.data['access_token'] as String;
      final newRefreshToken = res.data['refresh_token'] as String;

      _accessToken = newAccessToken;

      // ⭐️ 4. 응답받은 두 가지 토큰을 기기 내부 보안 저장소에 안전하게 저장 (자동 로그인의 핵심)
      await _tokenStorage.saveTokens(newAccessToken, newRefreshToken);

      // TODO: 실제 서버 응답에서 유저 정보를 받아 MainUser를 생성해야 합니다.
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
      // 서버에 로그아웃 요청 (세션/리프레시 토큰 서버 측 무효화)
      await ApiClient.dio.post('/logout');
    } catch (_) {
      // 서버 요청 실패해도 로컬 상태는 반드시 초기화
    }

    _currentUser = null;
    _accessToken = null;

    // ⭐️ 5. 로그아웃 시 기기에 저장된 토큰을 깔끔하게 파기
    await _tokenStorage.clearSessionTokens();
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final res = await ApiClient.dio.post(
        '/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      final newAccessToken = res.data['access_token'] as String;
      final newRefreshToken = res.data['refresh_token'] as String;

      _accessToken = newAccessToken;
      await _tokenStorage.saveTokens(newAccessToken, newRefreshToken);

      // TODO: 실제 서버 응답에서 유저 정보를 받아 MainUser를 생성해야 합니다.
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
