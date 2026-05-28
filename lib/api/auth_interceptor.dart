import 'package:dio/dio.dart';
import '/managers/token_storage_manager.dart';
import '/managers/login_manager.dart';
// // ================================================================
// // [MOCK - 삭제 대상] 실제 서버 연결 시 아래 import를 삭제하세요.
// import 'mock_server_interceptor.dart';
// // [MOCK - 삭제 끝] ================================================

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorageManager _storage = TokenStorageManager();

  AuthInterceptor(this.dio);

  // 동시에 401이 여러 번 발생해도 토큰 갱신 요청을 한 번만 보내기 위한 Future 공유
  static Future<String>? _refreshFuture;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return super.onError(err, handler);
    }

    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      await LoginManager().forceLogout('세션이 만료되었습니다. 다시 로그인해주세요.');
      return handler.reject(err);
    }

    try {
      // 이미 진행 중인 갱신이 있으면 그 Future를 공유 — 중복 /refresh 요청 방지
      _refreshFuture ??= _doRefresh(refreshToken);
      final newAccess = await _refreshFuture!;

      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      return handler.resolve(await dio.fetch(err.requestOptions));
    } catch (_) {
      await LoginManager().forceLogout('세션이 만료되었습니다. 다시 로그인해주세요.');
      return handler.reject(err);
    } finally {
      // 성공·실패 모두 Future 초기화 (다음 401에서 새로 시도)
      _refreshFuture = null;
    }
  }

  Future<String> _doRefresh(String refreshToken) async {
    final refreshDio = Dio(BaseOptions(baseUrl: 'http://168.110.102.12:8080'));
    // // ================================================================
    // // [MOCK - 삭제 대상] 실제 서버 연결 시 아래 줄을 삭제하세요.
    // refreshDio.interceptors.add(MockServerInterceptor());
    // // [MOCK - 삭제 끝] ================================================
    final res = await refreshDio.post(
      '/api/v1/auth/refresh',
      data: {'token': refreshToken},
    );
    final newAccess = res.data['accessToken'] as String;
    await _storage.saveTokens(newAccess, refreshToken);
    return newAccess;
  }
}
