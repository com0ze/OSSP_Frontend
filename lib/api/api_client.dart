import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

class ApiClient {
  static final Dio dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(BaseOptions(baseUrl: 'http://168.110.102.12:8080'));
    dio.interceptors.add(AuthInterceptor(dio));
    dio.interceptors.add(LogInterceptor(responseBody: true));
    return dio;
  }
}
