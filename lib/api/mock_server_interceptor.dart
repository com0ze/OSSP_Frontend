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

  // 항상 user 'u0'이 로그인한 것으로 간주
  static const String _currentUserId = 'u0';

  // ================================================================
  // 데이터 스토어
  // ================================================================

  final Map<String, User> _users = {
    'guest': User(id: 'guest', name: 'Guest'),
    'u0': User(id: 'u0', name: '김샘플', score: 4.5, rentalCount: 4),
    'u1': User(id: 'u1', name: '김철수', score: 4.2, rentalCount: 3),
    'u2': User(id: 'u2', name: '이영희', score: 4.0, rentalCount: 2),
    'u3': User(id: 'u3', name: '박민수', score: 5.0, rentalCount: 5),
    'u4': User(id: 'u4', name: '최유진', score: 3.9, rentalCount: 1),
    'u5': User(id: 'u5', name: '정수현', score: 4.1, rentalCount: 2),
    'u6': User(id: 'u6', name: '홍길동', score: 3.7, rentalCount: 1),
  };

  // u0이 받은 리뷰: rev_b4_by_u3(4), rev_l2_by_u2(5) → avg=4.5
  // u3이 받은 리뷰: rev_b4_by_u0(5) → score=5.0
  // u2이 받은 리뷰: rev_l2_by_u0(4) → score=4.0
  final Map<String, Review> _reviews = {
    // i_b4 대여 완료 후 양방향 리뷰 (u0↔u3, 자전거)
    'rev_b4_by_u0':
        Review(
            id: 'rev_b4_by_u0',
            score: 5.0,
            reviewText: '정확한 시간에 반납해 주셨어요. 다음에도 이용할게요!',
            writerId: 'u0',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          )
          ..revieweeId = 'u3'
          ..matchId = 'm_b4',
    'rev_b4_by_u3':
        Review(
            id: 'rev_b4_by_u3',
            score: 4.0,
            reviewText: '물건을 소중히 다뤄주셨습니다. 깨끗하게 사용해 주셔서 감사해요.',
            writerId: 'u3',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          )
          ..revieweeId = 'u0'
          ..matchId = 'm_b4',
    // i_l2 대여 완료 후 양방향 리뷰 (u0↔u2, 사다리)
    'rev_l2_by_u0':
        Review(
            id: 'rev_l2_by_u0',
            score: 4.0,
            reviewText: '약속 시간을 잘 지켜주셨고 물건도 깨끗하게 반납해 주셨어요.',
            writerId: 'u0',
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          )
          ..revieweeId = 'u2'
          ..matchId = 'm_l2',
    'rev_l2_by_u2':
        Review(
            id: 'rev_l2_by_u2',
            score: 5.0,
            reviewText: '빌려주신 분이 매우 친절하셨고 사다리 상태도 좋았습니다.',
            writerId: 'u2',
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          )
          ..revieweeId = 'u0'
          ..matchId = 'm_l2',
  };

  final Map<String, Chatting> _chattings = {
    // i_b2: u0이 u1에게 텐트 대여 중 (matchConfirmed)
    'c_b2': Chatting(
      id: 'c_b2',
      chats: [
        Chat(
          senderId: 'u1',
          content: '안녕하세요! 텐트 대여 수락했습니다. 어디서 만날까요?',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        Chat(
          senderId: 'u0',
          content: '원흥관 앞에서 만나도 괜찮을까요?',
          createdAt: DateTime.now().subtract(
            const Duration(hours: 4, minutes: 50),
          ),
        ),
        Chat(
          senderId: 'u1',
          content: '네 좋아요! 오늘 오후 3시 어떠세요?',
          createdAt: DateTime.now().subtract(
            const Duration(hours: 4, minutes: 45),
          ),
        ),
        Chat(
          senderId: 'u0',
          content: '알겠습니다. 그 때 뵐게요!',
          createdAt: DateTime.now().subtract(
            const Duration(hours: 4, minutes: 40),
          ),
        ),
      ],
    ),
    // i_b3: u0이 u2에게 빔프로젝터 대여 중 (inProgress)
    'c_b3': Chatting(
      id: 'c_b3',
      chats: [
        Chat(
          senderId: 'u2',
          content: '빔프로젝터 대여 수락했습니다!',
          createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        ),
        Chat(
          senderId: 'u0',
          content: '감사합니다! 전달 완료했습니다.',
          createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
        ),
        Chat(
          senderId: 'u2',
          content: '잘 사용하고 있어요. 반납은 내일 드릴게요.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    ),
    // i_b4: u0이 u3에게 자전거 반납 완료 (returned, 리뷰 완료)
    'c_b4': Chatting(
      id: 'c_b4',
      chats: [
        Chat(
          senderId: 'u3',
          content: '자전거 대여 수락했어요!',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Chat(
          senderId: 'u0',
          content: '감사합니다. 조심히 사용할게요.',
          createdAt: DateTime.now().subtract(
            const Duration(days: 4, hours: 23, minutes: 50),
          ),
        ),
        Chat(
          senderId: 'u3',
          content: '다 쓰셨나요?',
          createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
        ),
        Chat(
          senderId: 'u0',
          content: '네, 반납하겠습니다. 감사했습니다!',
          createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
        ),
      ],
    ),
    // i_b5: u0이 u4에게 청소기 반납 완료 (returned, 리뷰 미작성)
    'c_b5': Chatting(
      id: 'c_b5',
      chats: [
        Chat(
          senderId: 'u4',
          content: '청소기 대여 승인했습니다.',
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
        Chat(
          senderId: 'u0',
          content: '네 감사합니다!',
          createdAt: DateTime.now().subtract(
            const Duration(days: 7, hours: 23, minutes: 30),
          ),
        ),
        Chat(
          senderId: 'u4',
          content: '반납 확인했습니다. 감사해요!',
          createdAt: DateTime.now().subtract(const Duration(days: 6)),
        ),
      ],
    ),
    // i_l1: u0이 u1에게 카메라 대여 중 (matchConfirmed)
    'c_l1': Chatting(
      id: 'c_l1',
      chats: [
        Chat(
          senderId: 'u1',
          content: '미러리스 카메라 빌릴 수 있을까요?',
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        ),
        Chat(
          senderId: 'u0',
          content: '네 대여 수락했습니다! 신공학관 앞에서 만나요.',
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        ),
        Chat(
          senderId: 'u1',
          content: '알겠습니다 감사해요!',
          createdAt: DateTime.now().subtract(
            const Duration(days: 1, hours: 3, minutes: 50),
          ),
        ),
      ],
    ),
    // i_l2: u0이 u2에게 사다리 반납 완료 (returned, 리뷰 완료)
    'c_l2': Chatting(
      id: 'c_l2',
      chats: [
        Chat(
          senderId: 'u2',
          content: '사다리 감사히 사용했습니다!',
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
        Chat(
          senderId: 'u0',
          content: '소중히 다뤄주셔서 감사해요!',
          createdAt: DateTime.now().subtract(const Duration(days: 7, hours: 5)),
        ),
      ],
    ),
    // i_bc1: u0이 u5에게 킥보드 대여 신청 후 매치 취소
    'c_bc1': Chatting(
      id: 'c_bc1',
      chats: [
        Chat(
          senderId: 'u5',
          content: '킥보드 대여 수락했습니다!',
          createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 3)),
        ),
        Chat(
          senderId: 'u0',
          content: '감사합니다. 그런데 사정이 생겨서 취소해야 할 것 같아요.',
          createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 2)),
        ),
        Chat(
          senderId: 'u5',
          content: '아 그렇군요, 괜찮습니다!',
          createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 1)),
        ),
      ],
    ),
    // i_lc1: u6이 u0에게 텀블러 대여 신청 후 매치 취소
    'c_lc1': Chatting(
      id: 'c_lc1',
      chats: [
        Chat(
          senderId: 'u6',
          content: '텀블러 빌릴 수 있을까요?',
          createdAt: DateTime.now().subtract(const Duration(days: 6, hours: 5)),
        ),
        Chat(
          senderId: 'u0',
          content: '네, 대여 수락했습니다!',
          createdAt: DateTime.now().subtract(const Duration(days: 6, hours: 4)),
        ),
        Chat(
          senderId: 'u6',
          content: '죄송한데 갑자기 사정이 생겨서 취소해도 될까요?',
          createdAt: DateTime.now().subtract(const Duration(days: 6, hours: 2)),
        ),
        Chat(
          senderId: 'u0',
          content: '네, 괜찮아요!',
          createdAt: DateTime.now().subtract(const Duration(days: 6, hours: 1)),
        ),
      ],
    ),
  };

  final Map<String, Match> _matches = {
    // 빌린 물건 매치 (u0 = requester)
    'm_b2': const Match(
      matchID: 'm_b2',
      rentalItemID: 'i_b2',
      requesterID: 'u0',
      lenderID: 'u1',
      chattingID: 'c_b2',
    ),
    'm_b3': const Match(
      matchID: 'm_b3',
      rentalItemID: 'i_b3',
      requesterID: 'u0',
      lenderID: 'u2',
      chattingID: 'c_b3',
    ),
    'm_b4': const Match(
      matchID: 'm_b4',
      rentalItemID: 'i_b4',
      requesterID: 'u0',
      lenderID: 'u3',
      chattingID: 'c_b4',
    ),
    'm_b5': const Match(
      matchID: 'm_b5',
      rentalItemID: 'i_b5',
      requesterID: 'u0',
      lenderID: 'u4',
      chattingID: 'c_b5',
    ),
    // 빌려준 물건 매치 (u0 = lender)
    'm_l1': const Match(
      matchID: 'm_l1',
      rentalItemID: 'i_l1',
      requesterID: 'u1',
      lenderID: 'u0',
      chattingID: 'c_l1',
    ),
    'm_l2': const Match(
      matchID: 'm_l2',
      rentalItemID: 'i_l2',
      requesterID: 'u2',
      lenderID: 'u0',
      chattingID: 'c_l2',
    ),
    // 취소된 매치 (매치 후 취소)
    'm_bc1': const Match(
      matchID: 'm_bc1',
      rentalItemID: 'i_bc1',
      requesterID: 'u0',
      lenderID: 'u5',
      chattingID: 'c_bc1',
    ),
    'm_lc1': const Match(
      matchID: 'm_lc1',
      rentalItemID: 'i_lc1',
      requesterID: 'u6',
      lenderID: 'u0',
      chattingID: 'c_lc1',
    ),
  };

  final Map<String, RentalItem> _rentalItems = {
    // ── 빌린 물건 (u0 = requester) ─────────────────────────────────────────
    // 대기 중 (매칭 없음)
    'i_b1': RentalItem(
      id: 'i_b1',
      product: Product(name: '전동 드릴', category: '공구'),
      placeID: '신공학관',
      price: 10000,
      description: '가구 조립용으로 오늘 저녁까지 필요합니다',
      requesterID: 'u0',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    // 매칭 확정 (u1이 대여자)
    'i_b2': RentalItem(
      id: 'i_b2',
      product: Product(name: '4인용 텐트', category: '캠핑 용품'),
      placeID: '원흥관',
      price: 30000,
      description: '이번 주말 캠핑 가는데 텐트가 필요합니다',
      requesterID: 'u0',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      matchIDs: ['m_b2'],
      isMatched: true,
      matchedID: 'm_b2',
      rentalStatus: RentalStatus.matchConfirmed,
    ),
    // 대여 중 (u2가 대여자)
    'i_b3': RentalItem(
      id: 'i_b3',
      product: Product(name: '빔프로젝터', category: '전자기기'),
      placeID: '만해광장',
      price: 20000,
      description: '팀 발표용으로 이틀 정도 필요합니다',
      requesterID: 'u0',
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      matchIDs: ['m_b3'],
      isMatched: true,
      matchedID: 'm_b3',
      rentalStatus: RentalStatus.inProgress,
    ),
    // 반납 완료, 리뷰 작성 완료 (u3이 대여자)
    'i_b4': RentalItem(
      id: 'i_b4',
      product: Product(name: '자전거', category: '스포츠'),
      placeID: '학림관',
      price: 5000,
      description: '학교 안 단거리 이동용으로 하루 필요합니다',
      requesterID: 'u0',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      matchIDs: ['m_b4'],
      isMatched: true,
      matchedID: 'm_b4',
      rentalStatus: RentalStatus.returned,
    ),
    // 반납 완료, 리뷰 미작성 (u4가 대여자)
    'i_b5': RentalItem(
      id: 'i_b5',
      product: Product(name: '청소기', category: '생활용품'),
      placeID: '정보문화관',
      price: 8000,
      description: '방 청소용으로 반나절 필요합니다',
      requesterID: 'u0',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      matchIDs: ['m_b5'],
      isMatched: true,
      matchedID: 'm_b5',
      rentalStatus: RentalStatus.returned,
    ),
    // ── 빌려준 물건 (u0 = lender) ──────────────────────────────────────────
    // 매칭 확정 (u1이 요청자)
    'i_l1': RentalItem(
      id: 'i_l1',
      product: Product(name: '미러리스 카메라', category: '전자기기'),
      placeID: '신공학관',
      price: 25000,
      description: '여행 기념 사진 촬영용으로 이틀 빌리고 싶습니다',
      requesterID: 'u1',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      matchIDs: ['m_l1'],
      isMatched: true,
      matchedID: 'm_l1',
      rentalStatus: RentalStatus.matchConfirmed,
    ),
    // 반납 완료, 리뷰 작성 완료 (u2가 요청자)
    'i_l2': RentalItem(
      id: 'i_l2',
      product: Product(name: '사다리', category: '공구'),
      placeID: '원흥관',
      price: 3000,
      description: '전구 교체용으로 잠깐 필요합니다',
      requesterID: 'u2',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      matchIDs: ['m_l2'],
      isMatched: true,
      matchedID: 'm_l2',
      rentalStatus: RentalStatus.returned,
    ),
    // ── 취소된 거래 ────────────────────────────────────────────────────────────
    // 매치 후 취소 (u0 빌린 물건, u5가 대여자)
    'i_bc1': RentalItem(
      id: 'i_bc1',
      product: Product(name: '킥보드', category: '이동수단'),
      placeID: '신공학관',
      price: 5000,
      description: '캠퍼스 내 이동용으로 반나절 필요합니다',
      requesterID: 'u0',
      createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 4)),
      matchIDs: ['m_bc1'],
      isMatched: false,
      rentalStatus: RentalStatus.cancelled,
    ),
    // 매치 후 취소 (u6 빌린 물건, u0이 대여자)
    'i_lc1': RentalItem(
      id: 'i_lc1',
      product: Product(name: '텀블러', category: '생활용품'),
      placeID: '원흥관',
      price: 2000,
      description: '하루 동안 빌리고 싶습니다',
      requesterID: 'u6',
      requesterName: '홍길동',
      createdAt: DateTime.now().subtract(const Duration(days: 6, hours: 6)),
      matchIDs: ['m_lc1'],
      isMatched: false,
      rentalStatus: RentalStatus.cancelled,
    ),
    // 매치 전 취소 (u0 빌린 물건, 대여자 없음)
    'i_bc2': RentalItem(
      id: 'i_bc2',
      product: Product(name: '우산', category: '생활용품'),
      placeID: '만해광장',
      price: 1000,
      description: '비가 갑자기 와서 우산이 필요합니다',
      requesterID: 'u0',
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
      isMatched: false,
      rentalStatus: RentalStatus.cancelled,
    ),
    // ── 주변 대여 요청 (nearby, u0이 아닌 사용자들) ─────────────────────────
    'i_n1': RentalItem(
      id: 'i_n1',
      product: Product(name: '노트북 거치대', category: '전자기기'),
      placeID: '신공학관',
      price: 5000,
      description: '재택근무할 때 사용할 노트북 거치대 하루 빌려주실 분 구합니다',
      requesterID: 'u3',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    'i_n2': RentalItem(
      id: 'i_n2',
      product: Product(name: '자동차 점프 케이블', category: '자동차'),
      placeID: '정보문화관',
      price: 0,
      description: '배터리가 방전됐어요. 점프 케이블 잠깐만 빌려주실 분 계신가요?',
      requesterID: 'u4',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    'i_n3': RentalItem(
      id: 'i_n3',
      product: Product(name: '캠핑 버너', category: '캠핑 용품'),
      placeID: '만해광장',
      price: 15000,
      description: '이번 주 캠핑에서 사용할 버너를 구합니다. 3일 대여 원합니다',
      requesterID: 'u1',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  };

  // ================================================================
  // 비즈니스 로직
  // ================================================================

  bool _isActiveStatus(RentalStatus s) =>
      s == RentalStatus.pending ||
      s == RentalStatus.matchConfirmed ||
      s == RentalStatus.inProgress;

  RentalStatus _parseStatusParam(String status) {
    switch (status.toUpperCase()) {
      case 'WAITING':
        return RentalStatus.pending;
      case 'MATCHED':
        return RentalStatus.matchConfirmed;
      case 'IN_USE':
        return RentalStatus.inProgress;
      case 'COMPLETED':
        return RentalStatus.returned;
      case 'CANCELED':
        return RentalStatus.cancelled;
      default:
        return RentalStatus.pending;
    }
  }

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
    _reviews[reviewId] =
        Review(
            id: reviewId,
            score: score,
            reviewText: comments,
            writerId: reviewerId,
            createdAt: DateTime.now(),
          )
          ..revieweeId = revieweeId
          ..matchId = matchId;
    if (match != null) {
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
    final scores = _reviews.values
        .where((r) => r.revieweeId == userId)
        .map((r) => r.score)
        .toList();
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
    final hasMatch =
        item.rentalStatus == RentalStatus.matchConfirmed ||
        item.rentalStatus == RentalStatus.inProgress ||
        item.rentalStatus == RentalStatus.returned;
    final match = hasMatch && item.matchedID != null
        ? _matches[item.matchedID]
        : null;
    return {
      'requestId': item.id,
      'itemName': item.product.name,
      'buildingName': item.placeID,
      'rewardAmt': item.price,
      'duration': item.duration,
      'memo': item.description,
      'requesterId': item.requesterID,
      'requesterNickname': _users[item.requesterID]?.name ?? '알 수 없음',
      'createdAt': item.createdAt.toIso8601String(),
      'status': _statusToApi(item.rentalStatus),
      if (match != null) 'matchId': match.matchID,
      if (match != null) 'providerId': match.lenderID,
      if (match != null) 'roomId': match.chattingID,
    };
  }

  // GET /api/v1/users/me 전용 — email, isOnDuty 등 포함
  Map<String, dynamic> _meToApiJson(User user) => {
    'userId': user.id,
    'nickname': user.name,
    'email': 'test@dgu.ac.kr',
    'mannerScore': user.score,
    'currentBuilding': '신공학관',
    'isOnDuty': false,
    'role': 'USER',
    'createdAt': DateTime.now().toIso8601String(),
  };

  // GET /api/v1/users/{userId} 전용 — 공개 정보만
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

  // Spring Page 형식 페이징 응답
  Map<String, dynamic> _pageResponse(
    List<Map<String, dynamic>> content, {
    int page = 0,
    int size = 20,
  }) {
    return {
      'content': content,
      'pageable': {
        'pageNumber': page,
        'pageSize': size,
        'sort': {'empty': false, 'sorted': true, 'unsorted': false},
        'offset': page * size,
        'paged': true,
        'unpaged': false,
      },
      'totalElements': content.length,
      'totalPages': 1,
      'last': true,
      'size': size,
      'number': page,
      'sort': {'empty': false, 'sorted': true, 'unsorted': false},
      'numberOfElements': content.length,
      'first': true,
      'empty': content.isEmpty,
    };
  }

  // 특정 유저가 받은 리뷰 목록 (5.3/5.4 공용)
  List<Map<String, dynamic>> _receivedReviewsFor(String userId) {
    return _reviews.values
        .where((r) => r.revieweeId == userId)
        .map(
          (review) => {
            'reviewId': review.id,
            'matchId': review.matchId ?? '',
            'reviewerNickname': _users[review.writerId]?.name ?? '알 수 없음',
            'score': review.score,
            'comments': review.reviewText,
            'createdAt': review.createdAt.toIso8601String(),
          },
        )
        .toList();
  }

  // ================================================================
  // HTTP 핸들러
  // ================================================================

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future.delayed(const Duration(milliseconds: 10));

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

    // 1.1 회원가입 — 201 Created, 빈 바디
    if (method == 'POST' && path == '/api/v1/auth/signup') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 201,
          data: <String, dynamic>{},
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

    // ── 5.3 내가 받은 리뷰 목록 (/users/me 보다 먼저) ─────────────────────────

    if (method == 'GET' && path == '/api/v1/users/me/reviews') {
      final page =
          int.tryParse(options.queryParameters['page']?.toString() ?? '0') ?? 0;
      final size =
          int.tryParse(options.queryParameters['size']?.toString() ?? '20') ??
          20;
      final reviews = _receivedReviewsFor(_currentUserId);
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {'data': _pageResponse(reviews, page: page, size: size)},
        ),
      );
    }

    // ── 2.1 내 정보 ───────────────────────────────────────────────────────────

    if (method == 'GET' && path == '/api/v1/users/me') {
      final me = _users[_currentUserId]!;
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: _meToApiJson(me),
        ),
      );
    }

    // ── 3.2 대여 요청 전체 목록 ───────────────────────────────────────────────

    if (method == 'GET' && path == '/api/v1/requests') {
      final statusParam = options.queryParameters['status']?.toString();
      Iterable<RentalItem> items = _rentalItems.values;
      if (statusParam != null) {
        final target = _parseStatusParam(statusParam);
        items = items.where((i) => i.rentalStatus == target);
      }
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: items.map(_rentalItemToApiJson).toList(),
        ),
      );
    }

    // ── 3.4 주변 대여 요청 목록 ───────────────────────────────────────────────

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

    // ── 3.3 내 대여 요청 목록 ─────────────────────────────────────────────────

    if (method == 'GET' && path == '/api/v1/requests/me') {
      final statusParam = options.queryParameters['status']?.toString();
      final typeParam = options.queryParameters['type']?.toString();

      bool Function(RentalItem) filter;
      if (statusParam != null) {
        final target = _parseStatusParam(statusParam);
        filter = (i) => i.rentalStatus == target;
      } else if (typeParam == 'active') {
        filter = (i) => _isActiveStatus(i.rentalStatus);
      } else if (typeParam == 'history') {
        filter = (i) => !_isActiveStatus(i.rentalStatus);
      } else {
        filter = (i) => true;
      }

      final requesterItems = _rentalItems.values.where(
        (i) => i.requesterID == _currentUserId && filter(i),
      );
      final lenderItemIds = _matches.values
          .where((m) => m.lenderID == _currentUserId)
          .map((m) => m.rentalItemID)
          .toSet();
      final lenderItems = _rentalItems.values.where(
        (i) => lenderItemIds.contains(i.id) && filter(i),
      );

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

    // ── 3.1 대여 요청 생성 ─────────────────────────────────────────────────────

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
        requesterID: _currentUserId,
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

    // ── 3.6 대여 요청 수락 (매치 생성) ────────────────────────────────────────

    if (method == 'POST' &&
        path.startsWith('/api/v1/requests/') &&
        path.endsWith('/accept')) {
      final requestId = _extractSegment(path, 4);
      final body = options.data as Map<String, dynamic>;
      final providerId = body['providerId'].toString();
      try {
        final matchId = serverAcceptRequest(requestId, providerId);
        final match = _matches[matchId]!;
        final providerNickname = _users[providerId]?.name ?? '알 수 없음';
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'matchId': matchId,
              'requestId': requestId,
              'requestStatus': 'MATCHED',
              'requesterId': match.requesterID,
              'providerId': providerId,
              'providerNickname': providerNickname,
              'matchedAt': DateTime.now().toIso8601String(),
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

    // ── 3.7 대여 요청 취소 ─────────────────────────────────────────────────────

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

    // ── 3.7 물건 전달 (inProgress) ─────────────────────────────────────────────

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

    // ── 3.7 반납 완료 (returned) ───────────────────────────────────────────────

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

    // ── 3.5 대여 요청 단건 조회 ────────────────────────────────────────────────

    if (method == 'GET' && path.startsWith('/api/v1/requests/')) {
      final requestId = _extractSegment(path, 4);
      final item = _rentalItems[requestId];
      if (item == null) {
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
          data: _rentalItemToApiJson(item),
        ),
      );
    }

    // ── 4.2 채팅방 목록 ───────────────────────────────────────────────────────

    if (method == 'GET' && path == '/api/v1/chats') {
      final result = <Map<String, dynamic>>[];
      for (final match in _matches.values) {
        if (match.lenderID != _currentUserId &&
            match.requesterID != _currentUserId) {
          continue;
        }
        final chatting = _chattings[match.chattingID];
        if (chatting == null) continue;
        final opponentId = match.lenderID == _currentUserId
            ? match.requesterID
            : match.lenderID;
        final opponent = _users[opponentId];
        final lastChat = chatting.chats.isNotEmpty ? chatting.chats.last : null;
        result.add({
          'roomId': match.chattingID,
          'matchId': match.matchID,
          'requestId': match.rentalItemID,
          'opponentId': opponentId,
          'opponentName': opponent?.name ?? '알 수 없음',
          'lastMessage': lastChat?.content,
          'updatedAt':
              lastChat?.createdAt.toIso8601String() ??
              DateTime.now().toIso8601String(),
        });
      }
      return handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }

    // ── 4.3 채팅 메시지 조회 ──────────────────────────────────────────────────

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

    // ── 4.1 채팅방 생성 ───────────────────────────────────────────────────────

    if (method == 'POST' && path == '/api/v1/chats') {
      final body = options.data as Map<String, dynamic>;
      final matchId = body['matchId'].toString();
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
          data: {
            'roomId': match.chattingID,
            'matchId': matchId,
            'createdAt': DateTime.now().toIso8601String(),
          },
        ),
      );
    }

    // ── 채팅 메시지 전송 (REST fallback) ──────────────────────────────────────

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

    // ── 5.4 특정 유저가 받은 리뷰 목록 (/users/{userId} 보다 먼저) ─────────────

    if (method == 'GET' &&
        path.startsWith('/api/v1/users/') &&
        path.endsWith('/reviews')) {
      final userId = _extractSegment(path, 4);
      final page =
          int.tryParse(options.queryParameters['page']?.toString() ?? '0') ?? 0;
      final size =
          int.tryParse(options.queryParameters['size']?.toString() ?? '20') ??
          20;
      if (_users[userId] == null) {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 404),
          ),
        );
      }
      final reviews = _receivedReviewsFor(userId);
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {'data': _pageResponse(reviews, page: page, size: size)},
        ),
      );
    }

    // ── 2.2 유저 조회 ─────────────────────────────────────────────────────────

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

    // ── 2.3 유저 위치 업데이트 ────────────────────────────────────────────────

    if (method == 'PATCH' && path == '/api/v1/users/location') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );
    }

    // ── 2.5 FCM 토큰 업데이트 ─────────────────────────────────────────────────

    if (method == 'PATCH' && path == '/api/v1/users/me/device-token') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );
    }

    // ── 2.4 듀티 상태 업데이트 ────────────────────────────────────────────────

    if (method == 'PATCH' && path == '/api/v1/users/me/duty') {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );
    }

    // ── 5.1 리뷰 등록 ─────────────────────────────────────────────────────────

    if (method == 'POST' && path == '/api/v1/reviews') {
      final body = options.data as Map<String, dynamic>;
      final matchId = body['matchId'].toString();
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
          data: {
            'status': 'OK',
            'statusCode': 200,
            'message': '리뷰가 성공적으로 등록되었습니다.',
            'data': null,
          },
        ),
      );
    }

    // ── 5.2 내가 작성한 리뷰 목록 ─────────────────────────────────────────────

    if (method == 'GET' && path == '/api/v1/reviews/my') {
      final myReviews = _reviews.values
          .where((r) => r.writerId == _currentUserId)
          .map(
            (review) => {
              'reviewId': review.id,
              'reviewerId': review.writerId,
              'revieweeId': review.revieweeId ?? '',
              'score': review.score,
              'comments': review.reviewText,
              'matchId': review.matchId ?? '',
            },
          )
          .toList();
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'status': 'OK',
            'statusCode': 200,
            'message': '자신이 작성한 리뷰 목록입니다.',
            'data': myReviews,
          },
        ),
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
