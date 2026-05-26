import 'package:dio/dio.dart';

class ApiManager {
  static final ApiManager _instance = ApiManager._internal();
  factory ApiManager() => _instance;
  ApiManager._internal();

  // 실제 백엔드 배포 서버 주소 반영
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://168.110.102.12:8080',
    contentType: 'application/json',
  ));

  // TODO: 이후 여기에 JWT 토큰 자동 처리를 위한 Interceptor가 추가됩니다.
}