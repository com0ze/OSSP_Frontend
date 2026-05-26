import 'package:dio/dio.dart';
import 'package:open_source_software/managers/token_storage_manager.dart';
import 'package:open_source_software/managers/login_manager.dart';

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
      _refreshFuture ??= _doRefresh(refreshToken);
      final newAccess = await _refreshFuture!;

      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      return handler.resolve(await dio.fetch(err.requestOptions));
    } catch (_) {
      await LoginManager().forceLogout('세션이 만료되었습니다. 다시 로그인해주세요.');
      return handler.reject(err);
    } finally {
      _refreshFuture = null;
    }
  }

  Future<String> _doRefresh(String refreshToken) async {
    // 인터셉터 없는 별도 Dio로 순환 참조 방지
    final refreshDio = Dio(BaseOptions(baseUrl: 'http://168.110.102.12:8080'));
    final res = await refreshDio.post(
      '/api/v1/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    // auth 엔드포인트는 공통 래퍼 없이 직접 반환
    final newAccess = res.data['accessToken'] as String;
    final newRefresh = res.data['refreshToken'] as String;
    await TokenStorageManager().saveTokens(newAccess, newRefresh);
    return newAccess;
  }
}
