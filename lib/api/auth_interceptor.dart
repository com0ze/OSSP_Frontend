import 'package:dio/dio.dart';
import 'package:open_source_software/managers/token_storage_manager.dart';
import 'package:open_source_software/managers/login_manager.dart';
// ================================================================
// [MOCK - 삭제 대상] 실제 서버 연결 시 아래 import를 삭제하세요.
import 'mock_server_interceptor.dart';
// [MOCK - 삭제 끝] ================================================

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorageManager _storage = TokenStorageManager();

  AuthInterceptor(this.dio);

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
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        await LoginManager().logout();
        return handler.reject(err);
      }

      try {
        final refreshDio = Dio(BaseOptions(baseUrl: 'https://api.domain.com'));
        // ================================================================
        // [MOCK - 삭제 대상] 실제 서버 연결 시 아래 줄을 삭제하세요.
        refreshDio.interceptors.add(MockServerInterceptor());
        // [MOCK - 삭제 끝] ================================================
        final res = await refreshDio.post(
          '/refresh',
          data: {'token': refreshToken},
        );

        final newAccess = res.data['access_token'];
        await _storage.saveTokens(newAccess, refreshToken); // Refresh token 유지

        err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
        return handler.resolve(await dio.fetch(err.requestOptions));
      } catch (e) {
        await LoginManager().logout();
        return handler.reject(err);
      }
    }
    return super.onError(err, handler);
  }
}
