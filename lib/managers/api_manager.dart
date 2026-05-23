import 'package:dio/dio.dart';

class ApiManager {
  static final ApiManager _instance = ApiManager._internal();
  factory ApiManager() => _instance;
  ApiManager._internal();

  // 노션 명세서의 로컬 배포 주소 반영
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080',
    contentType: 'application/json',
  ));

  // TODO: 이후 여기에 JWT 토큰 자동 처리를 위한 Interceptor가 추가됩니다.
}