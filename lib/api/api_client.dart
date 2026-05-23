import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
// ================================================================
// [MOCK - 삭제 대상] 실제 서버 연결 시 아래 import를 삭제하세요.
import 'mock_server_interceptor.dart';
// [MOCK - 삭제 끝] ================================================

class ApiClient {
  static final Dio dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.domain.com'));
    dio.interceptors.add(AuthInterceptor(dio));
    dio.interceptors.add(LogInterceptor(responseBody: true));
    // ================================================================
    // [MOCK - 삭제 대상] 실제 서버 연결 시 아래 줄과 mock_server_interceptor.dart 파일을 삭제하세요.
    dio.interceptors.add(MockServerInterceptor());
    // [MOCK - 삭제 끝] ================================================
    return dio;
  }
}
