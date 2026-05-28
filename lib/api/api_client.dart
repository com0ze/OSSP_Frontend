import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_interceptor.dart';
// ================================================================
// [MOCK - 삭제 대상] 실제 서버 연결 시 아래 import를 삭제하세요.
import 'mock_server_interceptor.dart';
// [MOCK - 삭제 끝] ================================================

class ApiClient {
  // 1. 싱글톤 패턴 뼈대
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  // 2. Dio 객체를 담을 변수
  late final Dio dio;

  // 3. 내부 생성자에서 최초 1회 Dio 세팅
  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://168.110.102.12:8080', // 또는 실제 도메인
        contentType: 'application/json',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // 인터셉터 장착
    dio.interceptors.add(AuthInterceptor(dio));
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    }

    // ================================================================
    // [MOCK - 삭제 대상] 실제 서버 연결 시 아래 줄과 mock_server_interceptor.dart 파일을 삭제하세요.
    dio.interceptors.add(MockServerInterceptor());
    // [MOCK - 삭제 끝] ================================================
  }

  // 실서버 응답 wrapper {"status":..., "message":..., "data":{...}} 를 벗겨냄.
  // mock 서버처럼 data 필드가 없으면 그대로 반환.
  static dynamic extractData(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('data') &&
        (data.containsKey('status') || data.containsKey('message'))) {
      return data['data'];
    }
    return data;
  }
}
