import 'package:dio/dio.dart';
import '/models/chat.dart';
import '/models/chatting.dart';
import '/models/match.dart';
import '/models/product.dart';
import '/models/rental_item.dart';
import '/models/review.dart';
import '/models/user.dart';

class MockServerInterceptor extends Interceptor {
  static final MockServerInterceptor _instance =
      MockServerInterceptor._internal();
  factory MockServerInterceptor() => _instance;
  MockServerInterceptor._internal();

  // ================================================================
  // 인증용 가짜 토큰
  // ================================================================

  String _validAccessToken = 'valid_token_123';
  final String _validRefreshToken = 'refresh_token_456';

  // 항상 user '0'이 로그인한 것으로 간주
  static const String _currentUserId = '0';

  // ================================================================
  // 데이터 스토어
  // ================================================================

  final Map<String, User> _users = {
    'guest': User(id: 'guest', name: 'Guest'),
    '0': User(
      id: '0',
      name: 'Kim sample',
      score: 10.0,
    ),
    '1': User(
      id: '1',
      name: '김철수',
      score: 85,
      rentalCount: 3,
    ),
    '2': User(
      id: '2',
      name: '이영희',
      score: 92,
      rentalCount: 2,
    ),
    '3': User(
      id: '3',
      name: '박민수',
      score: 78,
      rentalCount: 1,
    ),
    'l1': User(id: 'l1', name: '김대여', score: 90),
    'l2': User(id: 'l2', name: '이빌려', score: 85),
    'r1': User(id: 'r1', name: '박여행', score: 82),
    'reviewer1': User(
      id: 'reviewer1',
      name: '김리뷰',
      score: 85,
    ),
    'reviewer2': User(
      id: 'reviewer2',
      name: '이후기',
      score: 90,
    ),
    'reviewer3': User(
      id: 'reviewer3',
      name: '박평가',
      score: 75,
    ),
  };

  final Map<String, Review> _reviews = {
    'b1': Review(
      id: 'b1',
      score: 5,
      reviewText: '잘 썼습니다.',
      writer: User(
        id: '0',
        name: 'Kim sample',
        score: 10.0,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    '1': Review(
      id: '1',
      score: 5,
      reviewText: '매우 친절하시고 물건 상태도 좋았습니다. 감사합니다!',
      writer: User(
        id: 'reviewer1',
        name: '김리뷰',
        score: 85,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    '2': Review(
      id: '2',
      score: 4,
      reviewText: '약속 시간도 잘 지키시고 좋았어요.',
      writer: User(
        id: 'reviewer2',
        name: '이후기',
        score: 90,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    '3': Review(
      id: '3',
      score: 4,
      reviewText: '대여 과정이 원활했습니다.',
      writer: User(
        id: 'reviewer3',
        name: '박평가',
        score: 75,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    // user '0'이 lender로서 이미 작성한 리뷰
    'rev_l_done': Review(
      id: 'rev_l_done',
      score: 5,
      reviewText: '요청자분이 매우 친절하셨습니다.',
      writer: User(id: '0', name: 'Kim sample', score: 10.0),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  };

  final Map<String, Chatting> _chattings = {
    'chat_m_b1': Chatting(id: 'chat_m_b1'),
    'chat_m_b2': Chatting(id: 'chat_m_b2'),
    'chat_m_b3': Chatting(id: 'chat_m_b3'),
    'chat_m_l1': Chatting(id: 'chat_m_l1'),
    'chat_m_l_done': Chatting(id: 'chat_m_l_done'),
    'chat_m_l_todo': Chatting(id: 'chat_m_l_todo'),
    'chat_m_ri1': Chatting(id: 'chat_m_ri1'),
    'chat_m_ri2': Chatting(id: 'chat_m_ri2'),
    'chat_m_ri3': Chatting(id: 'chat_m_ri3'),
    'c_test': Chatting(id: 'c_test'),
    'c_test2': Chatting(id: 'c_test2'),
  };

  final Map<String, Match> _matches = {
    'm_b1': const Match(
      matchID: 'm_b1',
      rentalItemID: 'b1',
      requesterID: '0',
      lenderID: '1',
      chattingID: 'chat_m_b1',
      requesterReviewID: 'b1',
    ),
    'm_b2': const Match(
      matchID: 'm_b2',
      rentalItemID: 'b2',
      requesterID: '0',
      lenderID: 'l1',
      chattingID: 'chat_m_b2',
    ),
    'm_b3': const Match(
      matchID: 'm_b3',
      rentalItemID: 'b3',
      requesterID: '0',
      lenderID: 'l2',
      chattingID: 'chat_m_b3',
    ),
    'm_l1': const Match(
      matchID: 'm_l1',
      rentalItemID: 'l1',
      requesterID: 'r1',
      lenderID: '0',
      chattingID: 'chat_m_l1',
    ),
    // user '0' = lender, 이미 리뷰 작성 완료 → 스낵바 표시
    'm_l_done': const Match(
      matchID: 'm_l_done',
      rentalItemID: 'l_done',
      requesterID: 'r1',
      lenderID: '0',
      chattingID: 'chat_m_l_done',
      lenderReviewID: 'rev_l_done',
    ),
    // user '0' = lender, 아직 리뷰 미작성 → 리뷰 화면 이동
    'm_l_todo': const Match(
      matchID: 'm_l_todo',
      rentalItemID: 'l_todo',
      requesterID: 'r1',
      lenderID: '0',
      chattingID: 'chat_m_l_todo',
    ),
    'm_ri1': const Match(
      matchID: 'm_ri1',
      rentalItemID: 'ri1',
      requesterID: '1',
      lenderID: 'reviewer1',
      chattingID: 'chat_m_ri1',
      lenderReviewID: '1',
    ),
    'm_ri2': const Match(
      matchID: 'm_ri2',
      rentalItemID: 'ri2',
      requesterID: '1',
      lenderID: 'reviewer2',
      chattingID: 'chat_m_ri2',
      lenderReviewID: '2',
    ),
    'm_ri3': const Match(
      matchID: 'm_ri3',
      rentalItemID: 'ri3',
      requesterID: '1',
      lenderID: 'reviewer3',
      chattingID: 'chat_m_ri3',
      lenderReviewID: '3',
    ),
    'm_test': const Match(
      matchID: 'm_test',
      rentalItemID: 'ri_test',
      requesterID: '1',
      lenderID: '0',
      chattingID: 'c_test',
    ),
    'm_test2': const Match(
      matchID: 'm_test2',
      rentalItemID: 'ri_test',
      requesterID: '1',
      lenderID: '2',
      chattingID: 'c_test2',
    ),
  };

  final Map<String, RentalItem> _rentalItems = {
    '1': RentalItem(
      id: '1',
      product: Product(name: '전동 드릴', category: '공구'),
      placeID: '신공학관',
      price: 10000,
      description: '가구 조립용으로 오늘 저녁까지 필요합니다',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    'qwer': RentalItem(
      id: 'qwer',
      product: Product(name: '전동 드릴', category: '공구'),
      placeID: '정보문화관',
      price: 10000,
      description: '가구 조립용으로 오늘 저녁까지 필요합니다',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    '2': RentalItem(
      id: '2',
      product: Product(name: '4인용 텐트', category: '캠핑 용품'),
      placeID: '원흥관',
      price: 30000,
      description: '이번 주말 캠핑 가는데 텐트가 필요합니다',
      requesterID: '2',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    '3': RentalItem(
      id: '3',
      product: Product(name: '빔프로젝터', category: '전자기기'),
      placeID: '만해광장',
      price: 20000,
      description: '회사 프레젠테이션용으로 필요합니다',
      requesterID: '3',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    'b1': RentalItem(
      id: 'b1',
      product: Product(name: '전동 드릴', category: '공구'),
      placeID: '원흥관',
      price: 10000,
      description: '가구 조립용',
      requesterID: '0',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      matchIDs: ['m_b1'],
      isMatched: true,
      matchedID: 'm_b1',
      rentalStatus: RentalStatus.returned,
    ),
    'b2': RentalItem(
      id: 'b2',
      product: Product(name: '전동 드릴', category: '공구'),
      placeID: '정보문화관',
      price: 10000,
      description: '가구 조립용',
      requesterID: '0',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      matchIDs: ['m_b2'],
      isMatched: true,
      matchedID: 'm_b2',
      rentalStatus: RentalStatus.inProgress,
    ),
    'b3': RentalItem(
      id: 'b3',
      product: Product(name: '4인용 텐트', category: '캠핑 용품'),
      placeID: '신공학관',
      price: 30000,
      description: '캠핑용',
      requesterID: '0',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      matchIDs: ['m_b3'],
      isMatched: true,
      matchedID: 'm_b3',
      rentalStatus: RentalStatus.returned,
    ),
    'l1': RentalItem(
      id: 'l1',
      product: Product(name: '미러리스 카메라', category: '전자기기'),
      placeID: '학림관',
      price: 25000,
      description: '여행용',
      requesterID: 'r1',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      matchIDs: ['m_l1'],
      isMatched: true,
      matchedID: 'm_l1',
      rentalStatus: RentalStatus.matchConfirmed,
    ),
    // user '0' = lender, returned, 이미 리뷰 작성 → 스낵바
    'l_done': RentalItem(
      id: 'l_done',
      product: Product(name: '자전거', category: '스포츠'),
      placeID: '원흥관',
      price: 5000,
      description: '단거리 이동용',
      requesterID: 'r1',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      matchIDs: ['m_l_done'],
      isMatched: true,
      matchedID: 'm_l_done',
      rentalStatus: RentalStatus.returned,
    ),
    // user '0' = lender, returned, 리뷰 미작성 → 리뷰 화면
    'l_todo': RentalItem(
      id: 'l_todo',
      product: Product(name: '자전거', category: '스포츠'),
      placeID: '원흥관',
      price: 5000,
      description: '단거리 이동용',
      requesterID: 'r1',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      matchIDs: ['m_l_todo'],
      isMatched: true,
      matchedID: 'm_l_todo',
      rentalStatus: RentalStatus.returned,
    ),
    'ri1': RentalItem(
      id: 'ri1',
      product: Product(name: '전동 드릴', category: '공구'),
      placeID: '',
      price: 0,
      description: '',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      matchIDs: ['m_ri1'],
      isMatched: true,
      matchedID: 'm_ri1',
      rentalStatus: RentalStatus.returned,
    ),
    'ri2': RentalItem(
      id: 'ri2',
      product: Product(name: '전동 드릴', category: '공구'),
      placeID: '',
      price: 0,
      description: '',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      matchIDs: ['m_ri2'],
      isMatched: true,
      matchedID: 'm_ri2',
      rentalStatus: RentalStatus.returned,
    ),
    'ri3': RentalItem(
      id: 'ri3',
      product: Product(name: '전동 드릴', category: '공구'),
      placeID: '',
      price: 0,
      description: '',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      matchIDs: ['m_ri3'],
      isMatched: true,
      matchedID: 'm_ri3',
      rentalStatus: RentalStatus.returned,
    ),
    'ri_test': RentalItem(
      id: 'ri_test',
      product: Product(name: '휴지', category: '생필품'),
      placeID: '신공학관',
      price: 1000,
      description: 'test',
      requesterID: '1',
      createdAt: DateTime.now(),
      matchIDs: ['m_test', 'm_test2'],
      isMatched: true,
      matchedID: 'm_test2',
      rentalStatus: RentalStatus.matchConfirmed,
    ),
  };

  // ================================================================
  // 비즈니스 로직
  // ================================================================

  bool _isActiveStatus(RentalStatus s) =>
      s == RentalStatus.pending ||
      s == RentalStatus.matchConfirmed ||
      s == RentalStatus.inProgress;

  // Returns created matchId
  String serverAcceptRequest(String requestId, String providerId) {
    final item = _rentalItems[requestId];
    if (item == null) throw Exception('Request not found: $requestId');
    final matchId = 'match_${requestId}_$providerId';
    final roomId = 'room_$matchId';
    _chattings[roomId] = Chatting(id: roomId);
    _matches[matchId] = Match(
      matchID: matchId,
      rentalItemID: requestId,
      requesterID: item.requesterID,
      lenderID: providerId,
      chattingID: roomId,
    );
    _rentalItems[requestId] = item.copyWith(
      matchIDs: [...item.matchIDs, matchId],
      isMatched: true,
      matchedID: matchId,
      rentalStatus: RentalStatus.matchConfirmed,
    );
    return matchId;
  }

  void serverCancelRequest(String requestId) {
    final item = _rentalItems[requestId];
    if (item == null) return;
    _rentalItems[requestId] = item.copyWith(
      isMatched: false,
      clearMatchedID: true,
      rentalStatus: RentalStatus.cancelled,
    );
  }

  void serverHandoverRequest(String requestId) {
    final item = _rentalItems[requestId];
    if (item == null) return;
    _rentalItems[requestId] = item.copyWith(
      rentalStatus: RentalStatus.inProgress,
    );
  }

  void serverCompleteRequest(String requestId) {
    final item = _rentalItems[requestId];
    if (item == null) return;
    _rentalItems[requestId] = item.copyWith(
      rentalStatus: RentalStatus.returned,
    );
    final match = item.matchedID != null ? _matches[item.matchedID] : null;
    if (match != null) {
      for (final uid in [match.lenderID, match.requesterID]) {
        final user = _users[uid];
        if (user != null) {
          _users[uid] = user.copyWith(rentalCount: user.rentalCount + 1);
        }
      }
    }
  }

  void serverAddChat(String roomId, Chat chat) {
    _chattings[roomId]?.addChat(chat);
  }

  void serverAddRequest(RentalItem item) {
    _rentalItems[item.id] = item;
  }

  String serverCreateReview({
    required String reviewerId,
    required String revieweeId,
    required String matchId,
    required double score,
    required String comments,
  }) {
    final match = _matches[matchId];
    final reviewId = 'review_${matchId}_$revieweeId';
    final reviewer =
        _users[reviewerId] ?? User(id: reviewerId, name: 'Unknown');
    _reviews[reviewId] = Review(
      id: reviewId,
      score: score,
      reviewText: comments,
      writer: reviewer,
      createdAt: DateTime.now(),
    );
    if (match != null) {
      if (revieweeId == match.requesterID) {
        _matches[matchId] = match.copyWith(lenderReviewID: reviewId);
      } else {
        _matches[matchId] = match.copyWith(requesterReviewID: reviewId);
      }
      final item = _rentalItems[match.rentalItemID];
      if (item != null) {
        _rentalItems[match.rentalItemID] = item.copyWith(
          rentalStatus: RentalStatus.returned,
        );
      }
      final newScore = _recalculateScore(revieweeId);
      final reviewee = _users[revieweeId];
      if (reviewee != null) {
        _users[revieweeId] = reviewee.copyWith(score: newScore);
      }
    }
    return reviewId;
  }

  double _recalculateScore(String userId) {
    final scores = <double>[];
    for (final match in _matches.values) {
      if (match.requesterID == userId && match.lenderReviewID != null) {
        final r = _reviews[match.lenderReviewID!];
        if (r != null) scores.add(r.score);
      }
      if (match.lenderID == userId && match.requesterReviewID != null) {
        final r = _reviews[match.requesterReviewID!];
        if (r != null) scores.add(r.score);
      }
    }
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  // ================================================================
  // 직렬화 헬퍼
  // ================================================================

  String _extractSegment(String path, int index) => path.split('/')[index];

  String _statusToApi(RentalStatus status) {
    switch (status) {
      case RentalStatus.pending:
        return 'WAITING';
      case RentalStatus.matchConfirmed:
        return 'MATCHED';
      case RentalStatus.inProgress:
        return 'IN_USE';
      case RentalStatus.returned:
        return 'COMPLETED';
      case RentalStatus.cancelled:
        return 'CANCELED';
      case RentalStatus.otherUserMatched:
        return 'WAITING';
    }
  }

  Map<String, dynamic> _rentalItemToApiJson(RentalItem item) {
    final match = item.matchedID != null ? _matches[item.matchedID] : null;
    return {
      'requestId': item.id,
      'itemName': item.product.name,
      'buildingName': item.placeID,
      'rewardAmt': item.price,
      'duration': item.duration,
      'memo': item.description,
      'requesterId': item.requesterID,
      'createdAt': item.createdAt.toIso8601String(),
      'status': _statusToApi(item.rentalStatus),
      if (match != null) 'matchId': match.matchID,
      if (match != null) 'providerId': match.lenderID,
      if (match != null) 'roomId': match.chattingID,
      if (match?.lenderReviewID != null) 'lenderReviewID': match!.lenderReviewID,
      if (match?.requesterReviewID != null) 'requesterReviewID': match!.requesterReviewID,
    };
  }

  Map<String, dynamic> _userToApiJson(User user) => {
    'userId': user.id,
    'nickname': user.name,
    'mannerScore': user.score,
  };

  Map<String, dynamic> _authTokenResponse() => {
    'grantType': 'Bearer',
    'accessToken': _validAccessToken,
    'refreshToken': _validRefreshToken,
  };

  // ================================================================
  // HTTP 핸들러
  // ================================================================

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final path = options.path;
    final method = options.method;

    // ── 인증 (토큰 불필요) ────────────────────────────────────────────────────

    if (method == 'POST' && path == '/api/v1/auth/login') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: _authTokenResponse(),
        ),
      );
    }

    if (method == 'POST' && path == '/api/v1/auth/signup') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: _authTokenResponse(),
        ),
      );
    }

    if (method == 'POST' && path == '/api/v1/auth/refresh') {
      _validAccessToken =
          'refreshed_token_${DateTime.now().millisecondsSinceEpoch}';
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: _authTokenResponse(),
        ),
      );
    }

    if (method == 'POST' && path == '/api/v1/auth/logout') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );
    }

    // ── 토큰 검증 ─────────────────────────────────────────────────────────────

    final authHeader = options.headers['Authorization'];
    if (authHeader != 'Bearer $_validAccessToken') {
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 401),
        ),
      );
    }

    // ── 내 정보 ───────────────────────────────────────────────────────────────

    if (method == 'GET' && path == '/api/v1/users/me') {
      final me = _users[_currentUserId]!;
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: _userToApiJson(me),
        ),
      );
    }

    // ── 대여 요청 목록 ────────────────────────────────────────────────────────

    if (method == 'GET' && path == '/api/v1/requests/nearby') {
      final items = _rentalItems.values
          .where(
            (i) =>
                i.rentalStatus == RentalStatus.pending &&
                i.requesterID != _currentUserId,
          )
          .map(_rentalItemToApiJson)
          .toList();
      return handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: items),
      );
    }

    if (method == 'GET' && path == '/api/v1/requests/me') {
      final type = options.queryParameters['type'] as String? ?? 'active';
      // userId 파라미터는 현재 mock에서는 무시하고 항상 _currentUserId 사용
      final isActive = type == 'active';

      // Items where current user is requester
      final requesterItems = _rentalItems.values.where(
        (i) =>
            i.requesterID == _currentUserId &&
            (isActive
                ? _isActiveStatus(i.rentalStatus)
                : !_isActiveStatus(i.rentalStatus)),
      );

      // Items where current user is lender (via confirmed match)
      final lenderItemIds = _matches.values
          .where((m) => m.lenderID == _currentUserId)
          .map((m) => m.rentalItemID)
          .toSet();
      final lenderItems = isActive
          ? _rentalItems.values.where(
              (i) =>
                  lenderItemIds.contains(i.id) &&
                  _isActiveStatus(i.rentalStatus),
            )
          : <RentalItem>[];

      final merged = <String, RentalItem>{};
      for (final i in [...requesterItems, ...lenderItems]) {
        merged[i.id] = i;
      }
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: merged.values.map(_rentalItemToApiJson).toList(),
        ),
      );
    }

    // ── 대여 요청 생성 ─────────────────────────────────────────────────────────

    if (method == 'POST' && path == '/api/v1/requests') {
      final body = options.data as Map<String, dynamic>;
      final id = 'req_${DateTime.now().millisecondsSinceEpoch}';
      final item = RentalItem(
        id: id,
        product: Product(
          name: body['itemName'] as String? ?? '',
          category: '기타',
        ),
        placeID: body['buildingName'] as String? ?? '',
        price: (body['rewardAmt'] as num? ?? 0).toInt(),
        duration: (body['duration'] as num? ?? 3600).toInt(),
        description: body['memo'] as String? ?? '',
        requesterID: body['requesterId'] as String? ?? _currentUserId,
        createdAt: DateTime.now(),
      );
      serverAddRequest(item);
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 201,
          data: _rentalItemToApiJson(item),
        ),
      );
    }

    // ── 대여 요청 수락 (매치 생성) ────────────────────────────────────────────

    if (method == 'POST' &&
        path.startsWith('/api/v1/requests/') &&
        path.endsWith('/accept')) {
      final requestId = _extractSegment(path, 4);
      final body = options.data as Map<String, dynamic>;
      final providerId = body['providerId'] as String;
      try {
        final matchId = serverAcceptRequest(requestId, providerId);
        final match = _matches[matchId]!;
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'matchId': matchId,
              'requestId': requestId,
              'requesterId': match.requesterID,
              'providerId': providerId,
            },
          ),
        );
      } catch (_) {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 404),
          ),
        );
      }
    }

    // ── 대여 요청 취소 ─────────────────────────────────────────────────────────

    if (method == 'PATCH' &&
        path.startsWith('/api/v1/requests/') &&
        path.endsWith('/cancel')) {
      final requestId = _extractSegment(path, 4);
      serverCancelRequest(requestId);
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );
    }

    // ── 물건 전달 (inProgress) ─────────────────────────────────────────────────

    if (method == 'PATCH' &&
        path.startsWith('/api/v1/requests/') &&
        path.endsWith('/handover')) {
      final requestId = _extractSegment(path, 4);
      serverHandoverRequest(requestId);
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );
    }

    // ── 반납 완료 (returned) ───────────────────────────────────────────────────

    if (method == 'PATCH' &&
        path.startsWith('/api/v1/requests/') &&
        path.endsWith('/complete')) {
      final requestId = _extractSegment(path, 4);
      serverCompleteRequest(requestId);
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );
    }

    // ── 채팅방 목록 ───────────────────────────────────────────────────────────

    if (method == 'GET' && path == '/api/v1/chats') {
      final result = <Map<String, dynamic>>[];
      for (final match in _matches.values) {
        if (match.lenderID != _currentUserId &&
            match.requesterID != _currentUserId) {
          continue;
        }
        final chatting = _chattings[match.chattingID];
        if (chatting == null) {
          continue;
        }
        final opponentId = match.lenderID == _currentUserId
            ? match.requesterID
            : match.lenderID;
        final opponent = _users[opponentId];
        final lastChat =
            chatting.chats.isNotEmpty ? chatting.chats.last : null;
        result.add({
          'roomId': match.chattingID,
          'matchId': match.matchID,
          'requestId': match.rentalItemID,
          'opponentId': opponentId,
          'opponentName': opponent?.name ?? '알 수 없음',
          'lastMessage': lastChat?.content,
          'updatedAt': lastChat?.createdAt.toIso8601String() ??
              DateTime.now().toIso8601String(),
        });
      }
      return handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }

    // ── 채팅 메시지 조회 ──────────────────────────────────────────────────────

    if (method == 'GET' &&
        path.startsWith('/api/v1/chats/') &&
        path.endsWith('/messages')) {
      final roomId = _extractSegment(path, 4);
      final chatting = _chattings[roomId];
      if (chatting == null) {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 404),
          ),
        );
      }
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: chatting.chats.map((c) => c.toJson()).toList(),
        ),
      );
    }

    // ── 채팅방 생성 ───────────────────────────────────────────────────────────

    if (method == 'POST' && path == '/api/v1/chats') {
      final body = options.data as Map<String, dynamic>;
      final matchId = body['matchId'] as String;
      final match = _matches[matchId];
      if (match == null) {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 404),
          ),
        );
      }
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {'roomId': match.chattingID},
        ),
      );
    }

    // ── 채팅 메시지 전송 ──────────────────────────────────────────────────────

    if (method == 'POST' &&
        path.startsWith('/api/v1/chats/') &&
        path.endsWith('/messages')) {
      final roomId = _extractSegment(path, 4);
      final chat = Chat.fromJson(options.data as Map<String, dynamic>);
      serverAddChat(roomId, chat);
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 201,
          data: <String, dynamic>{},
        ),
      );
    }

    // ── 유저 조회 ─────────────────────────────────────────────────────────────

    if (method == 'GET' && path.startsWith('/api/v1/users/')) {
      final userId = _extractSegment(path, 4);
      final user = _users[userId];
      if (user == null) {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 404),
          ),
        );
      }
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: _userToApiJson(user),
        ),
      );
    }

    // ── 유저 위치 업데이트 ────────────────────────────────────────────────────

    if (method == 'PATCH' && path == '/api/v1/users/location') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );
    }

    // ── FCM 토큰 업데이트 ─────────────────────────────────────────────────────

    if (method == 'PATCH' && path == '/api/v1/users/me/device-token') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );
    }

    // ── 듀티 상태 업데이트 ────────────────────────────────────────────────────

    if (method == 'PATCH' && path == '/api/v1/users/me/duty') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );
    }

    // ── 리뷰 등록 ─────────────────────────────────────────────────────────────

    if (method == 'POST' && path == '/api/v1/reviews') {
      final body = options.data as Map<String, dynamic>;
      final matchId = body['matchId'] as String;
      final match = _matches[matchId];
      // 서버는 인증 토큰으로 reviewer를 판단 — mock은 _currentUserId로 대체
      final reviewerId = _currentUserId;
      final revieweeId = match?.lenderID == _currentUserId
          ? match?.requesterID ?? ''
          : match?.lenderID ?? '';
      serverCreateReview(
        reviewerId: reviewerId,
        revieweeId: revieweeId,
        matchId: matchId,
        score: (body['score'] as num).toDouble(),
        comments: body['comments'] as String? ?? '',
      );
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );
    }

    // ── 내가 작성한 리뷰 목록 ─────────────────────────────────────────────────
    if (method == 'GET' && path == '/api/v1/reviews/my') {
      final myReviews = <Map<String, dynamic>>[];
      for (final match in _matches.values) {
        if (match.lenderID == _currentUserId && match.lenderReviewID != null) {
          final review = _reviews[match.lenderReviewID!];
          if (review != null) {
            myReviews.add({
              'reviewId': review.id,
              'reviewerId': _currentUserId,
              'revieweeId': match.requesterID,
              'score': review.score,
              'comments': review.reviewText,
              'matchId': match.matchID,
              'writerNickname': review.writer.name,
              'createdAt': review.createdAt.toIso8601String(),
            });
          }
        }
        if (match.requesterID == _currentUserId &&
            match.requesterReviewID != null) {
          final review = _reviews[match.requesterReviewID!];
          if (review != null) {
            myReviews.add({
              'reviewId': review.id,
              'reviewerId': _currentUserId,
              'revieweeId': match.lenderID,
              'score': review.score,
              'comments': review.reviewText,
              'matchId': match.matchID,
              'writerNickname': review.writer.name,
              'createdAt': review.createdAt.toIso8601String(),
            });
          }
        }
      }
      return handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: myReviews),
      );
    }

    // ── 미처리 요청 ───────────────────────────────────────────────────────────

    return handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 200,
        data: <String, dynamic>{},
      ),
    );
  }
}
