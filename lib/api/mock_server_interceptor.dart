import 'package:dio/dio.dart';

class MockServerInterceptor extends Interceptor {
  static final MockServerInterceptor _instance =
      MockServerInterceptor._internal();
  factory MockServerInterceptor() => _instance;
  MockServerInterceptor._internal();

  // 테스트용 가짜 데이터
  String validAccessToken = 'valid_token_123';
  String validRefreshToken = 'refresh_token_456';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 실제 서버 통신처럼 0.5초 딜레이를 줍니다.
    await Future.delayed(const Duration(milliseconds: 500));

    // 1. 로그인 API 테스트
    if (options.path == '/login') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'access_token': validAccessToken,
            'refresh_token': validRefreshToken,
          },
        ),
      );
    }

    // 2. 회원가입 API 테스트 (토큰 없이 접근 가능)
    if (options.path == '/register') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'access_token': validAccessToken,
            'refresh_token': validRefreshToken,
          },
        ),
      );
    }

    // 3. 토큰 갱신 API 테스트
    if (options.path == '/refresh') {
      // 새로운 가짜 토큰 발급
      validAccessToken = 'new_valid_token_789';
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'access_token': validAccessToken,
            'refresh_token': validRefreshToken,
          },
        ),
      );
    }

    // 4. 로그아웃 API 테스트 (토큰 만료 여부와 상관없이 항상 성공 반환)
    if (options.path == '/logout') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {'message': '로그아웃 되었습니다.'},
        ),
      );
    }

    // 5. 이후 모든 API는 토큰 검증 필요
    final authHeader = options.headers['Authorization'];

    // 헤더에 있는 토큰이 'validAccessToken'과 다르면 무조건 401 에러를 던집니다.
    if (authHeader != 'Bearer $validAccessToken') {
      print('🤖 [MockServer] 토큰이 만료되었거나 틀렸습니다! 401 에러를 던집니다.');
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 401),
        ),
      );
    }

    // 6. 내 정보 조회 API 테스트
    if (options.path == '/me') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'id': '0',
            'name': 'Kim sample',
            'email': 'user@dgu.ac.kr',
            'score': 10.0,
            'personal_information': 'Sample user information',
          },
        ),
      );
    }

    // 7. 그 외 일반 API 테스트
    print('🤖 [MockServer] 토큰 정상! 데이터를 반환합니다.');
    return handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 200,
        data: {'message': '성공적으로 데이터를 가져왔습니다!', 'items': []},
      ),
    );
  }
}
