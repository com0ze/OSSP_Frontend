import 'package:dio/dio.dart';
import 'package:open_source_software/models/chat.dart';
import 'package:open_source_software/models/chatting.dart';
import 'package:open_source_software/models/match.dart';
import 'package:open_source_software/models/product.dart';
import 'package:open_source_software/models/rental_item.dart';
import 'package:open_source_software/models/review.dart';
import 'package:open_source_software/models/user.dart';

class MockServerInterceptor extends Interceptor {
  static final MockServerInterceptor _instance =
      MockServerInterceptor._internal();
  factory MockServerInterceptor() => _instance;
  MockServerInterceptor._internal();

  // ================================================================
  // 인증용 가짜 토큰 (기존)
  // ================================================================

  String _validAccessToken = 'valid_token_123';
  final String _validRefreshToken = 'refresh_token_456';

  // ================================================================
  // 데이터 스토어 (TestDataManager에서 이전)
  // TestDataManager가 이 싱글톤의 스냅샷을 캐시로 사용
  // ================================================================

  final Map<String, User> _users = {
    'guest': User(id: 'guest', name: 'Guest', email: ''),
    '0': User(
      id: '0',
      name: 'Kim sample',
      email: 'test@email.com',
      score: 10.0,
    ),
    '1': User(
      id: '1',
      name: '김철수',
      email: 'kim@example.com',
      score: 85,
      rentalHistory: ['deal1', 'deal2', 'deal3'],
    ),
    '2': User(
      id: '2',
      name: '이영희',
      email: 'lee@example.com',
      score: 92,
      rentalHistory: ['deal4', 'deal5'],
    ),
    '3': User(
      id: '3',
      name: '박민수',
      email: 'park@example.com',
      score: 78,
      rentalHistory: ['deal6'],
    ),
    'l1': User(id: 'l1', name: '김대여', email: 'lender@example.com', score: 90),
    'l2': User(id: 'l2', name: '이빌려', email: 'lender2@example.com', score: 85),
    'r1': User(id: 'r1', name: '박여행', email: 'renter@example.com', score: 82),
    'reviewer1': User(
      id: 'reviewer1',
      name: '김리뷰',
      email: 'reviewer1@example.com',
      score: 85,
    ),
    'reviewer2': User(
      id: 'reviewer2',
      name: '이후기',
      email: 'reviewer2@example.com',
      score: 90,
    ),
    'reviewer3': User(
      id: 'reviewer3',
      name: '박평가',
      email: 'reviewer3@example.com',
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
        email: 'test@email.com',
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
        email: 'reviewer1@example.com',
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
        email: 'reviewer2@example.com',
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
        email: 'reviewer3@example.com',
        score: 75,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  };

  final Map<String, Chatting> _chattings = {
    'chat_m_b1': Chatting(id: 'chat_m_b1'),
    'chat_m_b2': Chatting(id: 'chat_m_b2'),
    'chat_m_b3': Chatting(id: 'chat_m_b3'),
    'chat_m_l1': Chatting(id: 'chat_m_l1'),
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
      title: '급하게 드릴 필요해요',
      product: Product(name: '전동 드릴', category: '공구'),
      location: '서울시 강남구',
      price: 10000,
      description: '가구 조립용으로 오늘 저녁까지 필요합니다',
      preferences: '오늘 저녁까지 필요합니다',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    'qwer': RentalItem(
      id: 'qwer',
      title: '급하게 드릴 필요해요',
      product: Product(name: '전동 드릴', category: '공구'),
      location: '서울시 강남구',
      price: 10000,
      description: '가구 조립용으로 오늘 저녁까지 필요합니다',
      preferences: '오늘 저녁까지 필요합니다',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    '2': RentalItem(
      id: '2',
      title: '캠핑용 텐트 빌려주실 분',
      product: Product(name: '4인용 텐트', category: '캠핑 용품'),
      location: '서울시 마포구',
      price: 30000,
      description: '이번 주말 캠핑 가는데 텐트가 필요합니다',
      preferences: '금요일 오후에 수령 가능합니다',
      requesterID: '2',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    '3': RentalItem(
      id: '3',
      title: '빔프로젝터 급구',
      product: Product(name: '빔프로젝트', category: '전자기기'),
      location: '서울시 송파구',
      price: 20000,
      description: '회사 프레젠테이션용으로 필요합니다',
      preferences: '내일 오전까지 필요',
      requesterID: '3',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    'b1': RentalItem(
      id: 'b1',
      title: '드릴 대여',
      product: Product(name: '전동 드릴', category: '공구'),
      location: '서울시 강남구',
      price: 10000,
      description: '가구 조립용',
      preferences: '',
      requesterID: '0',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      matchIDs: ['m_b1'],
      isMatched: true,
      matchedID: 'm_b1',
      rentalStatus: RentalStatus.reviewed,
    ),
    'b2': RentalItem(
      id: 'b2',
      title: '드릴 대여',
      product: Product(name: '전동 드릴', category: '공구'),
      location: '서울시 강남구',
      price: 10000,
      description: '가구 조립용',
      preferences: '',
      requesterID: '0',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      matchIDs: ['m_b2'],
      isMatched: true,
      matchedID: 'm_b2',
      rentalStatus: RentalStatus.inProgress,
    ),
    'b3': RentalItem(
      id: 'b3',
      title: '캠핑 텐트',
      product: Product(name: '4인용 텐트', category: '캠핑 용품'),
      location: '서울시 마포구',
      price: 30000,
      description: '캠핑용',
      preferences: '',
      requesterID: '0',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      matchIDs: ['m_b3'],
      isMatched: true,
      matchedID: 'm_b3',
      rentalStatus: RentalStatus.returned,
    ),
    'l1': RentalItem(
      id: 'l1',
      title: '카메라 대여',
      product: Product(name: '미러리스 카메라', category: '전자기기'),
      location: '서울시 송파구',
      price: 25000,
      description: '여행용',
      preferences: '',
      requesterID: 'r1',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      matchIDs: ['m_l1'],
      isMatched: true,
      matchedID: 'm_l1',
      rentalStatus: RentalStatus.matchConfirmed,
    ),
    'ri1': RentalItem(
      id: 'ri1',
      title: '',
      product: Product(name: '전동 드릴', category: '공구'),
      location: '',
      price: 0,
      description: '',
      preferences: '',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      matchIDs: ['m_ri1'],
      isMatched: true,
      matchedID: 'm_ri1',
      rentalStatus: RentalStatus.reviewed,
    ),
    'ri2': RentalItem(
      id: 'ri2',
      title: '',
      product: Product(name: '전동 드릴', category: '공구'),
      location: '',
      price: 0,
      description: '',
      preferences: '',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      matchIDs: ['m_ri2'],
      isMatched: true,
      matchedID: 'm_ri2',
      rentalStatus: RentalStatus.reviewed,
    ),
    'ri3': RentalItem(
      id: 'ri3',
      title: '',
      product: Product(name: '전동 드릴', category: '공구'),
      location: '',
      price: 0,
      description: '',
      preferences: '',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      matchIDs: ['m_ri3'],
      isMatched: true,
      matchedID: 'm_ri3',
      rentalStatus: RentalStatus.reviewed,
    ),
    'ri_test': RentalItem(
      id: 'ri_test',
      title: 'ri_test',
      product: Product(name: '휴지', category: '생필품'),
      location: '신공학관',
      price: 1000,
      description: 'test',
      preferences: 'test',
      requesterID: '1',
      createdAt: DateTime.now(),
      matchIDs: ['m_test', 'm_test2'],
      isMatched: true,
      matchedID: 'm_test2',
      rentalStatus: RentalStatus.matchConfirmed,
    ),
  };

  // ================================================================
  // 스냅샷 Getter — TestDataManager가 캐시 갱신 시 사용
  // ================================================================

  Map<String, User> get usersSnapshot => Map.from(_users);
  Map<String, Review> get reviewsSnapshot => Map.from(_reviews);
  Map<String, Chatting> get chattingsSnapshot => Map.from(_chattings);
  Map<String, Match> get matchesSnapshot => Map.from(_matches);
  Map<String, RentalItem> get rentalItemsSnapshot => Map.from(_rentalItems);

  // ================================================================
  // 비즈니스 로직 (TestDataManager에서 이전)
  // ================================================================

  Match serverCreateMatchWithChatting(String rentalItemId, String lenderId) {
    final item = _rentalItems[rentalItemId]!;
    final matchId = 'match_${rentalItemId}_$lenderId';
    final chattingId = 'chat_$matchId';
    _chattings[chattingId] = Chatting(id: chattingId);
    final newMatch = Match(
      matchID: matchId,
      rentalItemID: rentalItemId,
      requesterID: item.requesterID,
      lenderID: lenderId,
      chattingID: chattingId,
    );
    _matches[matchId] = newMatch;
    _rentalItems[rentalItemId] = item.copyWith(
      matchIDs: [...item.matchIDs, matchId],
    );
    return newMatch;
  }

  void serverConfirmMatch(String matchId) {
    final match = _matches[matchId];
    if (match == null) return;
    final item = _rentalItems[match.rentalItemID];
    if (item != null) {
      _rentalItems[match.rentalItemID] = item.copyWith(
        isMatched: true,
        matchedID: matchId,
        rentalStatus: RentalStatus.matchConfirmed,
      );
    }
  }

  void serverCancelAllMatchesForItem(String rentalItemId) {
    final item = _rentalItems[rentalItemId];
    if (item != null) {
      _rentalItems[rentalItemId] = item.copyWith(
        isMatched: false,
        clearMatchedID: true,
        rentalStatus: RentalStatus.cancelled,
      );
    }
  }

  void serverCancelLenderMatch(String matchId) {
    final match = _matches[matchId];
    if (match == null) return;
    final item = _rentalItems[match.rentalItemID];
    if (item != null) {
      _rentalItems[match.rentalItemID] = item.copyWith(
        isMatched: false,
        clearMatchedID: true,
        rentalStatus: RentalStatus.pending,
      );
    }
  }

  void serverUpdateMatchStatus(String matchId, RentalStatus newStatus) {
    final match = _matches[matchId];
    if (match == null) return;
    final item = _rentalItems[match.rentalItemID];
    if (item != null) {
      _rentalItems[match.rentalItemID] = item.copyWith(rentalStatus: newStatus);
    }
    if (newStatus == RentalStatus.returned) {
      final itemId = match.rentalItemID;
      final lender = _users[match.lenderID];
      if (lender != null && !lender.rentalHistory.contains(itemId)) {
        _users[match.lenderID] = lender.copyWith(
          rentalHistory: [...lender.rentalHistory, itemId],
        );
      }
      final requester = _users[match.requesterID];
      if (requester != null && !requester.rentalHistory.contains(itemId)) {
        _users[match.requesterID] = requester.copyWith(
          rentalHistory: [...requester.rentalHistory, itemId],
        );
      }
    }
  }

  void serverUpdateMatchLenderReview(String matchId, Review newReview) {
    final match = _matches[matchId];
    if (match == null) return;
    _reviews[newReview.id] = newReview;
    _matches[matchId] = match.copyWith(lenderReviewID: newReview.id);
    final item = _rentalItems[match.rentalItemID];
    if (item != null) {
      _rentalItems[match.rentalItemID] = item.copyWith(
        rentalStatus: RentalStatus.reviewed,
      );
    }
    final newScore = _recalculateScore(match.requesterID);
    final requester = _users[match.requesterID];
    if (requester != null) {
      _users[match.requesterID] = requester.copyWith(score: newScore);
    }
  }

  void serverUpdateMatchRequesterReview(String matchId, Review newReview) {
    final match = _matches[matchId];
    if (match == null) return;
    _reviews[newReview.id] = newReview;
    _matches[matchId] = match.copyWith(requesterReviewID: newReview.id);
    final item = _rentalItems[match.rentalItemID];
    if (item != null) {
      _rentalItems[match.rentalItemID] = item.copyWith(
        rentalStatus: RentalStatus.reviewed,
      );
    }
    final newScore = _recalculateScore(match.lenderID);
    final lender = _users[match.lenderID];
    if (lender != null) {
      _users[match.lenderID] = lender.copyWith(score: newScore);
    }
  }

  void serverAddChat(String chattingId, Chat chat) {
    _chattings[chattingId]?.addChat(chat);
  }

  void serverAddRentalItem(RentalItem item) {
    _rentalItems[item.id] = item;
  }

  double _recalculateScore(String userId) {
    final scores = <int>[];
    for (final match in _matches.values) {
      if (match.requesterID == userId && match.lenderReviewID != null) {
        final review = _reviews[match.lenderReviewID!];
        if (review != null) scores.add(review.score);
      }
      if (match.lenderID == userId && match.requesterReviewID != null) {
        final review = _reviews[match.requesterReviewID!];
        if (review != null) scores.add(review.score);
      }
    }
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  // ================================================================
  // HTTP 핸들러
  // ================================================================

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // 1. 로그인
    if (options.path == '/login') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'access_token': _validAccessToken,
            'refresh_token': _validRefreshToken,
          },
        ),
      );
    }

    // 2. 회원가입 (토큰 없이 접근 가능)
    if (options.path == '/register') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'access_token': _validAccessToken,
            'refresh_token': _validRefreshToken,
          },
        ),
      );
    }

    // 3. 토큰 갱신
    if (options.path == '/refresh') {
      _validAccessToken = 'new_valid_token_789';
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'access_token': _validAccessToken,
            'refresh_token': _validRefreshToken,
          },
        ),
      );
    }

    // 4. 로그아웃 (토큰 만료 여부 무관)
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
    if (authHeader != 'Bearer $_validAccessToken') {
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 401),
        ),
      );
    }

    // 6. 내 정보 조회
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

    // 7. 그 외 일반 API
    return handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 200,
        data: {'message': '성공적으로 데이터를 가져왔습니다!', 'items': []},
      ),
    );
  }
}
